-- =============================================
-- DEPLOY BATCH 16: Stored Procedures
-- Componentes: pagosdivfrm, polcon, prepagofrm, pres, proyecfrm
-- Base de datos: multas_reglamentos
-- Fecha: 2025-11-23
-- =============================================

-- ===========================================
-- PAGOSDIVFRM (Pagos Diversos)
-- ===========================================

-- Obtener información de cuenta para pagos diversos
CREATE OR REPLACE FUNCTION pagosdivfrm_sp_get(
    p_cuenta VARCHAR,
    p_rfc VARCHAR DEFAULT ''
) RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'cuenta', json_build_object(
            'cuenta', c.cuenta,
            'contribuyente', c.contribuyente,
            'domicilio', c.domicilio,
            'rfc', c.rfc
        ),
        'historial', (
            SELECT COALESCE(json_agg(
                json_build_object(
                    'folio', p.folio,
                    'concepto', p.concepto,
                    'descripcion', p.descripcion,
                    'monto', p.monto,
                    'forma_pago', p.forma_pago,
                    'fecha', p.fecha
                ) ORDER BY p.fecha DESC
            ), '[]'::json)
            FROM pagos_diversos p
            WHERE p.cuenta = c.cuenta
        )
    ) INTO v_result
    FROM cuentas c
    WHERE c.cuenta = p_cuenta
    AND (p_rfc = '' OR c.rfc = p_rfc);

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Registrar pago diverso
CREATE OR REPLACE FUNCTION pagosdivfrm_sp_pagar(
    p_cuenta VARCHAR,
    p_concepto VARCHAR,
    p_descripcion VARCHAR,
    p_monto NUMERIC,
    p_forma VARCHAR,
    p_referencia VARCHAR DEFAULT ''
) RETURNS JSON AS $$
DECLARE
    v_folio VARCHAR;
BEGIN
    v_folio := 'DIV-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(NEXTVAL('seq_pagos_diversos')::TEXT, 6, '0');

    INSERT INTO pagos_diversos (
        folio, cuenta, concepto, descripcion, monto, forma_pago, referencia, fecha, usuario
    ) VALUES (
        v_folio, p_cuenta, p_concepto, p_descripcion, p_monto, p_forma, p_referencia, CURRENT_TIMESTAMP, CURRENT_USER
    );

    RETURN json_build_object('success', true, 'folio', v_folio);
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- POLCON (Políticas y Control)
-- ===========================================

-- Listar políticas de control
CREATE OR REPLACE FUNCTION polcon_sp_list(
    p_q VARCHAR DEFAULT '',
    p_tipo VARCHAR DEFAULT '',
    p_estado VARCHAR DEFAULT ''
) RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'rows', COALESCE(json_agg(
            json_build_object(
                'id', p.id,
                'nombre', p.nombre,
                'tipo', p.tipo,
                'descripcion', p.descripcion,
                'valor', p.valor,
                'es_porcentaje', p.es_porcentaje,
                'fecha_inicio', p.fecha_inicio,
                'fecha_fin', p.fecha_fin,
                'activo', p.activo
            ) ORDER BY p.id DESC
        ), '[]'::json)
    ) INTO v_result
    FROM politicas_control p
    WHERE (p_q = '' OR p.nombre ILIKE '%' || p_q || '%' OR p.descripcion ILIKE '%' || p_q || '%')
    AND (p_tipo = '' OR p.tipo = p_tipo)
    AND (p_estado = '' OR (p_estado = 'activo' AND p.activo = true) OR (p_estado = 'inactivo' AND p.activo = false));

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Guardar política
CREATE OR REPLACE FUNCTION polcon_sp_save(
    p_id INTEGER,
    p_nombre VARCHAR,
    p_tipo VARCHAR,
    p_descripcion VARCHAR,
    p_valor NUMERIC,
    p_es_porcentaje BOOLEAN,
    p_fecha_inicio VARCHAR,
    p_fecha_fin VARCHAR,
    p_activo BOOLEAN
) RETURNS JSON AS $$
BEGIN
    IF p_id = 0 OR p_id IS NULL THEN
        INSERT INTO politicas_control (
            nombre, tipo, descripcion, valor, es_porcentaje, fecha_inicio, fecha_fin, activo
        ) VALUES (
            p_nombre, p_tipo, p_descripcion, p_valor, p_es_porcentaje,
            p_fecha_inicio::DATE, p_fecha_fin::DATE, p_activo
        );
    ELSE
        UPDATE politicas_control SET
            nombre = p_nombre,
            tipo = p_tipo,
            descripcion = p_descripcion,
            valor = p_valor,
            es_porcentaje = p_es_porcentaje,
            fecha_inicio = p_fecha_inicio::DATE,
            fecha_fin = p_fecha_fin::DATE,
            activo = p_activo
        WHERE id = p_id;
    END IF;

    RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql;

-- Eliminar política
CREATE OR REPLACE FUNCTION polcon_sp_delete(p_id INTEGER) RETURNS JSON AS $$
BEGIN
    DELETE FROM politicas_control WHERE id = p_id;
    RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- PREPAGOFRM (Prepago)
-- ===========================================

-- Calcular opciones de prepago
CREATE OR REPLACE FUNCTION prepagofrm_sp_calcular(
    p_cuenta VARCHAR,
    p_anio INTEGER
) RETURNS JSON AS $$
DECLARE
    v_result JSON;
    v_monto_anual NUMERIC;
BEGIN
    -- Calcular monto anual base
    SELECT COALESCE(SUM(adeudo), 0) INTO v_monto_anual
    FROM adeudos_predial
    WHERE cuenta = p_cuenta AND anio = p_anio;

    SELECT json_build_object(
        'cuenta', json_build_object(
            'cuenta', c.cuenta,
            'contribuyente', c.contribuyente,
            'domicilio', c.domicilio
        ),
        'opciones', json_build_array(
            json_build_object(
                'meses', 12,
                'descripcion', 'Anual Completo',
                'descuento', 10,
                'monto_original', v_monto_anual,
                'monto_final', v_monto_anual * 0.90,
                'ahorro', v_monto_anual * 0.10
            ),
            json_build_object(
                'meses', 6,
                'descripcion', 'Semestral',
                'descuento', 5,
                'monto_original', v_monto_anual * 0.5,
                'monto_final', v_monto_anual * 0.5 * 0.95,
                'ahorro', v_monto_anual * 0.5 * 0.05
            ),
            json_build_object(
                'meses', 3,
                'descripcion', 'Trimestral',
                'descuento', 3,
                'monto_original', v_monto_anual * 0.25,
                'monto_final', v_monto_anual * 0.25 * 0.97,
                'ahorro', v_monto_anual * 0.25 * 0.03
            )
        ),
        'historial', (
            SELECT COALESCE(json_agg(
                json_build_object(
                    'folio', pp.folio,
                    'anio', pp.anio,
                    'meses', pp.meses,
                    'descuento', pp.descuento,
                    'monto', pp.monto,
                    'fecha', pp.fecha,
                    'aplicado', pp.aplicado
                ) ORDER BY pp.fecha DESC
            ), '[]'::json)
            FROM prepagos pp
            WHERE pp.cuenta = c.cuenta
        )
    ) INTO v_result
    FROM cuentas c
    WHERE c.cuenta = p_cuenta;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Aplicar prepago
CREATE OR REPLACE FUNCTION prepagofrm_sp_aplicar(
    p_cuenta VARCHAR,
    p_anio INTEGER,
    p_meses INTEGER,
    p_monto NUMERIC,
    p_forma VARCHAR,
    p_referencia VARCHAR DEFAULT ''
) RETURNS JSON AS $$
DECLARE
    v_folio VARCHAR;
    v_descuento NUMERIC;
BEGIN
    -- Calcular descuento según meses
    v_descuento := CASE
        WHEN p_meses = 12 THEN 10
        WHEN p_meses = 6 THEN 5
        WHEN p_meses = 3 THEN 3
        ELSE 0
    END;

    v_folio := 'PP-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(NEXTVAL('seq_prepagos')::TEXT, 6, '0');

    INSERT INTO prepagos (
        folio, cuenta, anio, meses, descuento, monto, forma_pago, referencia, fecha, aplicado, usuario
    ) VALUES (
        v_folio, p_cuenta, p_anio, p_meses, v_descuento, p_monto, p_forma, p_referencia, CURRENT_TIMESTAMP, true, CURRENT_USER
    );

    RETURN json_build_object('success', true, 'folio', v_folio);
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- PRES (Prescripciones)
-- ===========================================

-- Listar prescripciones
CREATE OR REPLACE FUNCTION pres_sp_list(
    p_cuenta VARCHAR DEFAULT '',
    p_anio_desde INTEGER DEFAULT 0,
    p_anio_hasta INTEGER DEFAULT 0,
    p_estado VARCHAR DEFAULT '',
    p_concepto VARCHAR DEFAULT ''
) RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'rows', COALESCE(json_agg(
            json_build_object(
                'cuenta', a.cuenta,
                'contribuyente', c.contribuyente,
                'concepto', a.concepto,
                'anio', a.anio,
                'bimestre', a.bimestre,
                'monto', a.monto,
                'fecha_vencimiento', a.fecha_vencimiento,
                'estado', a.estado_prescripcion,
                'anios_transcurridos', EXTRACT(YEAR FROM AGE(CURRENT_DATE, a.fecha_vencimiento)),
                'observaciones', a.observaciones
            ) ORDER BY a.anio DESC, a.bimestre DESC
        ), '[]'::json)
    ) INTO v_result
    FROM adeudos a
    INNER JOIN cuentas c ON c.cuenta = a.cuenta
    WHERE (p_cuenta = '' OR a.cuenta = p_cuenta)
    AND (p_anio_desde = 0 OR a.anio >= p_anio_desde)
    AND (p_anio_hasta = 0 OR a.anio <= p_anio_hasta)
    AND (p_estado = '' OR a.estado_prescripcion = p_estado)
    AND (p_concepto = '' OR a.concepto = p_concepto)
    AND a.fecha_vencimiento < CURRENT_DATE;

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Aplicar prescripción
CREATE OR REPLACE FUNCTION pres_sp_aplicar(
    p_cuenta VARCHAR,
    p_anio INTEGER,
    p_bimestre INTEGER,
    p_concepto VARCHAR
) RETURNS JSON AS $$
BEGIN
    UPDATE adeudos SET
        estado_prescripcion = 'prescrito',
        fecha_prescripcion = CURRENT_TIMESTAMP,
        usuario_prescripcion = CURRENT_USER
    WHERE cuenta = p_cuenta
    AND anio = p_anio
    AND bimestre = p_bimestre
    AND concepto = p_concepto;

    RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- PROYECFRM (Proyectos de Cobranza)
-- ===========================================

-- Listar proyectos
CREATE OR REPLACE FUNCTION proyecfrm_sp_list(
    p_q VARCHAR DEFAULT '',
    p_estado VARCHAR DEFAULT '',
    p_anio VARCHAR DEFAULT ''
) RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'rows', COALESCE(json_agg(
            json_build_object(
                'id', p.id,
                'nombre', p.nombre,
                'descripcion', p.descripcion,
                'estado', p.estado,
                'meta', p.meta,
                'recaudado', COALESCE(p.recaudado, 0),
                'cuentas_asignadas', p.cuentas_asignadas,
                'fecha_inicio', p.fecha_inicio,
                'fecha_fin', p.fecha_fin,
                'responsable', p.responsable
            ) ORDER BY p.id DESC
        ), '[]'::json)
    ) INTO v_result
    FROM proyectos_cobranza p
    WHERE (p_q = '' OR p.nombre ILIKE '%' || p_q || '%' OR p.descripcion ILIKE '%' || p_q || '%')
    AND (p_estado = '' OR p.estado = p_estado)
    AND (p_anio = '' OR EXTRACT(YEAR FROM p.fecha_inicio) = p_anio::INTEGER);

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Guardar proyecto
CREATE OR REPLACE FUNCTION proyecfrm_sp_save(
    p_id INTEGER,
    p_nombre VARCHAR,
    p_descripcion VARCHAR,
    p_estado VARCHAR,
    p_meta NUMERIC,
    p_cuentas_asignadas INTEGER,
    p_fecha_inicio VARCHAR,
    p_fecha_fin VARCHAR,
    p_responsable VARCHAR
) RETURNS JSON AS $$
BEGIN
    IF p_id = 0 OR p_id IS NULL THEN
        INSERT INTO proyectos_cobranza (
            nombre, descripcion, estado, meta, cuentas_asignadas, fecha_inicio, fecha_fin, responsable, recaudado
        ) VALUES (
            p_nombre, p_descripcion, p_estado, p_meta, p_cuentas_asignadas,
            p_fecha_inicio::DATE, p_fecha_fin::DATE, p_responsable, 0
        );
    ELSE
        UPDATE proyectos_cobranza SET
            nombre = p_nombre,
            descripcion = p_descripcion,
            estado = p_estado,
            meta = p_meta,
            cuentas_asignadas = p_cuentas_asignadas,
            fecha_inicio = p_fecha_inicio::DATE,
            fecha_fin = p_fecha_fin::DATE,
            responsable = p_responsable
        WHERE id = p_id;
    END IF;

    RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql;

-- Eliminar proyecto
CREATE OR REPLACE FUNCTION proyecfrm_sp_delete(p_id INTEGER) RETURNS JSON AS $$
BEGIN
    DELETE FROM proyectos_cobranza WHERE id = p_id;
    RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- Crear secuencias necesarias
-- ===========================================

CREATE SEQUENCE IF NOT EXISTS seq_pagos_diversos START 1;
CREATE SEQUENCE IF NOT EXISTS seq_prepagos START 1;

-- ===========================================
-- FIN DEL DEPLOY BATCH 16
-- ===========================================
