-- =====================================================
-- STORED PROCEDURES PARA ASEO CONTRATADO
-- Generado: 2025-12-02
-- =====================================================

-- Schema para aseo_contratado
CREATE SCHEMA IF NOT EXISTS aseo_contratado;

-- =====================================================
-- 1. SP_ASEO_CONTRATOS_LIST - Listar contratos
-- =====================================================
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_contratos_list(
    p_ctrol_aseo INTEGER DEFAULT NULL,
    p_status VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    num_empresa INTEGER,
    nombre_empresa VARCHAR,
    ctrol_emp INTEGER,
    ctrol_recolec INTEGER,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    zona_desc VARCHAR,
    id_rec SMALLINT,
    recaudadora VARCHAR,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig TIMESTAMP,
    cve VARCHAR,
    usuario INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        COALESCE(ta.tipo_aseo, '')::VARCHAR AS tipo_aseo,
        c.num_empresa,
        COALESCE(e.descripcion, '')::VARCHAR AS nombre_empresa,
        c.ctrol_emp,
        c.ctrol_recolec,
        c.cantidad_recolec,
        c.domicilio::VARCHAR,
        c.sector::VARCHAR,
        c.ctrol_zona,
        COALESCE(z.descripcion, '')::VARCHAR AS zona_desc,
        c.id_rec,
        COALESCE(r.recaudadora, '')::VARCHAR AS recaudadora,
        c.fecha_hora_alta,
        c.status_vigencia::VARCHAR,
        c.aso_mes_oblig,
        c.cve::VARCHAR,
        c.usuario
    FROM comun.ta_16_contratos c
    LEFT JOIN aseo_contratado.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    LEFT JOIN aseo_contratado.ta_16_empresas e ON c.num_empresa = e.num_empresa
    LEFT JOIN aseo_contratado.ta_16_zonas z ON c.ctrol_zona = z.ctrol_zona
    LEFT JOIN comun.ta_12_recaudadoras r ON c.id_rec = r.id_rec
    WHERE (p_ctrol_aseo IS NULL OR c.ctrol_aseo = p_ctrol_aseo)
      AND (p_status IS NULL OR c.status_vigencia = p_status)
    ORDER BY c.control_contrato DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 2. SP_ASEO_CONTRATOS_GET - Obtener contrato por ID
-- =====================================================
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_contratos_get(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    num_empresa INTEGER,
    nombre_empresa VARCHAR,
    representante VARCHAR,
    ctrol_emp INTEGER,
    ctrol_recolec INTEGER,
    cve_recolec VARCHAR,
    desc_recolec VARCHAR,
    costo_unidad NUMERIC,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    zona_desc VARCHAR,
    id_rec SMALLINT,
    recaudadora VARCHAR,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig TIMESTAMP,
    cve VARCHAR,
    usuario INTEGER,
    monto_mensual NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        COALESCE(ta.tipo_aseo, '')::VARCHAR,
        c.num_empresa,
        COALESCE(e.descripcion, '')::VARCHAR,
        COALESCE(e.representante, '')::VARCHAR,
        c.ctrol_emp,
        c.ctrol_recolec,
        COALESCE(u.cve_recolec, '')::VARCHAR,
        COALESCE(u.descripcion, '')::VARCHAR,
        COALESCE(u.costo_unidad, 0)::NUMERIC,
        c.cantidad_recolec,
        c.domicilio::VARCHAR,
        c.sector::VARCHAR,
        c.ctrol_zona,
        COALESCE(z.descripcion, '')::VARCHAR,
        c.id_rec,
        COALESCE(r.recaudadora, '')::VARCHAR,
        c.fecha_hora_alta,
        c.status_vigencia::VARCHAR,
        c.aso_mes_oblig,
        c.cve::VARCHAR,
        c.usuario,
        (COALESCE(u.costo_unidad, 0) * c.cantidad_recolec)::NUMERIC
    FROM comun.ta_16_contratos c
    LEFT JOIN aseo_contratado.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    LEFT JOIN aseo_contratado.ta_16_empresas e ON c.num_empresa = e.num_empresa
    LEFT JOIN aseo_contratado.ta_16_zonas z ON c.ctrol_zona = z.ctrol_zona
    LEFT JOIN comun.ta_12_recaudadoras r ON c.id_rec = r.id_rec
    LEFT JOIN comun.ta_16_unidades u ON c.ctrol_recolec = u.ctrol_recolec
        AND EXTRACT(YEAR FROM c.aso_mes_oblig) = u.ejercicio_recolec
    WHERE c.control_contrato = p_control_contrato;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 3. SP_ASEO_CONTRATOS_CREATE - Crear contrato con pagos
-- =====================================================
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_contratos_create(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,
    p_ctrol_recolec INTEGER,
    p_cantidad_recolec SMALLINT,
    p_domicilio VARCHAR,
    p_sector VARCHAR,
    p_ctrol_zona INTEGER,
    p_id_rec SMALLINT,
    p_fecha_oblig DATE,
    p_cve VARCHAR DEFAULT 'A',
    p_usuario INTEGER DEFAULT 0
)
RETURNS TABLE(
    control_contrato INTEGER,
    success BOOLEAN,
    message VARCHAR,
    pagos_generados INTEGER
) AS $$
DECLARE
    v_control_contrato INTEGER;
    v_existe_empresa INTEGER;
    v_existe_contrato INTEGER;
    v_mes_inicio INTEGER;
    v_anio INTEGER;
    v_anio_sig INTEGER;
    v_costo_unidad NUMERIC;
    v_costo_unidad_sig NUMERIC;
    v_importe NUMERIC;
    v_pagos_count INTEGER := 0;
    v_mes INTEGER;
BEGIN
    -- Validar empresa existe
    SELECT COUNT(*) INTO v_existe_empresa
    FROM aseo_contratado.ta_16_empresas
    WHERE num_empresa = p_num_empresa;

    IF v_existe_empresa = 0 THEN
        RETURN QUERY SELECT 0, FALSE, 'La empresa no existe'::VARCHAR, 0;
        RETURN;
    END IF;

    -- Validar contrato no existe
    SELECT COUNT(*) INTO v_existe_contrato
    FROM comun.ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;

    IF v_existe_contrato > 0 THEN
        RETURN QUERY SELECT 0, FALSE, 'El contrato ya existe para este tipo de aseo'::VARCHAR, 0;
        RETURN;
    END IF;

    -- Obtener siguiente control_contrato
    SELECT COALESCE(MAX(control_contrato), 0) + 1 INTO v_control_contrato
    FROM comun.ta_16_contratos;

    -- Insertar contrato
    INSERT INTO comun.ta_16_contratos (
        control_contrato, num_contrato, ctrol_aseo, num_empresa, ctrol_emp,
        ctrol_recolec, cantidad_recolec, domicilio, sector, ctrol_zona,
        id_rec, fecha_hora_alta, status_vigencia, aso_mes_oblig, cve, usuario
    ) VALUES (
        v_control_contrato, p_num_contrato, p_ctrol_aseo, p_num_empresa, p_ctrol_emp,
        p_ctrol_recolec, p_cantidad_recolec, p_domicilio, p_sector, p_ctrol_zona,
        p_id_rec, NOW(), 'V', p_fecha_oblig, p_cve, p_usuario
    );

    -- Generar pagos mensuales
    v_mes_inicio := EXTRACT(MONTH FROM p_fecha_oblig)::INTEGER;
    v_anio := EXTRACT(YEAR FROM p_fecha_oblig)::INTEGER;
    v_anio_sig := v_anio + 1;

    -- Obtener costo de unidad para el año
    SELECT COALESCE(costo_unidad, 0) INTO v_costo_unidad
    FROM comun.ta_16_unidades
    WHERE ejercicio_recolec = v_anio AND ctrol_recolec = p_ctrol_recolec
    LIMIT 1;

    -- Obtener costo para el año siguiente
    SELECT COALESCE(costo_unidad, 0) INTO v_costo_unidad_sig
    FROM comun.ta_16_unidades
    WHERE ejercicio_recolec = v_anio_sig AND ctrol_recolec = p_ctrol_recolec
    LIMIT 1;

    -- Generar pagos del año actual (desde mes inicio hasta diciembre)
    FOR v_mes IN v_mes_inicio..12 LOOP
        v_importe := v_costo_unidad * p_cantidad_recolec;

        INSERT INTO comun.ta_16_pagos (
            control_contrato, aso_mes_pago, ctrol_operacion, importe,
            status_vigencia, usuario, exedencias
        ) VALUES (
            v_control_contrato,
            make_date(v_anio, v_mes, 1),
            6, -- Cuota normal
            v_importe,
            'V',
            p_usuario,
            p_cantidad_recolec
        );
        v_pagos_count := v_pagos_count + 1;
    END LOOP;

    -- Generar pagos del año siguiente (enero a diciembre) si hay costo definido
    IF v_costo_unidad_sig > 0 THEN
        FOR v_mes IN 1..12 LOOP
            v_importe := v_costo_unidad_sig * p_cantidad_recolec;

            INSERT INTO comun.ta_16_pagos (
                control_contrato, aso_mes_pago, ctrol_operacion, importe,
                status_vigencia, usuario, exedencias
            ) VALUES (
                v_control_contrato,
                make_date(v_anio_sig, v_mes, 1),
                6, -- Cuota normal
                v_importe,
                'V',
                p_usuario,
                p_cantidad_recolec
            );
            v_pagos_count := v_pagos_count + 1;
        END LOOP;
    END IF;

    RETURN QUERY SELECT v_control_contrato, TRUE, 'Contrato creado exitosamente'::VARCHAR, v_pagos_count;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 4. SP_ASEO_CONTRATOS_UPDATE - Actualizar contrato
-- =====================================================
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_contratos_update(
    p_control_contrato INTEGER,
    p_num_empresa INTEGER DEFAULT NULL,
    p_ctrol_emp INTEGER DEFAULT NULL,
    p_ctrol_recolec INTEGER DEFAULT NULL,
    p_cantidad_recolec SMALLINT DEFAULT NULL,
    p_domicilio VARCHAR DEFAULT NULL,
    p_sector VARCHAR DEFAULT NULL,
    p_ctrol_zona INTEGER DEFAULT NULL,
    p_id_rec SMALLINT DEFAULT NULL,
    p_usuario INTEGER DEFAULT 0
)
RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
DECLARE
    v_existe INTEGER;
BEGIN
    -- Validar contrato existe
    SELECT COUNT(*) INTO v_existe
    FROM comun.ta_16_contratos
    WHERE control_contrato = p_control_contrato;

    IF v_existe = 0 THEN
        RETURN QUERY SELECT FALSE, 'El contrato no existe'::VARCHAR;
        RETURN;
    END IF;

    -- Actualizar solo los campos proporcionados
    UPDATE comun.ta_16_contratos
    SET
        num_empresa = COALESCE(p_num_empresa, num_empresa),
        ctrol_emp = COALESCE(p_ctrol_emp, ctrol_emp),
        ctrol_recolec = COALESCE(p_ctrol_recolec, ctrol_recolec),
        cantidad_recolec = COALESCE(p_cantidad_recolec, cantidad_recolec),
        domicilio = COALESCE(p_domicilio, domicilio),
        sector = COALESCE(p_sector, sector),
        ctrol_zona = COALESCE(p_ctrol_zona, ctrol_zona),
        id_rec = COALESCE(p_id_rec, id_rec)
    WHERE control_contrato = p_control_contrato;

    RETURN QUERY SELECT TRUE, 'Contrato actualizado exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 5. SP_ASEO_CONTRATOS_BAJA - Dar de baja contrato
-- =====================================================
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_contratos_baja(
    p_control_contrato INTEGER,
    p_usuario INTEGER DEFAULT 0
)
RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
DECLARE
    v_existe INTEGER;
    v_status VARCHAR;
BEGIN
    -- Validar contrato existe
    SELECT COUNT(*), MAX(status_vigencia) INTO v_existe, v_status
    FROM comun.ta_16_contratos
    WHERE control_contrato = p_control_contrato
    GROUP BY control_contrato;

    IF v_existe = 0 THEN
        RETURN QUERY SELECT FALSE, 'El contrato no existe'::VARCHAR;
        RETURN;
    END IF;

    IF v_status = 'B' THEN
        RETURN QUERY SELECT FALSE, 'El contrato ya está dado de baja'::VARCHAR;
        RETURN;
    END IF;

    -- Dar de baja el contrato
    UPDATE comun.ta_16_contratos
    SET
        status_vigencia = 'B',
        fecha_hora_baja = NOW()
    WHERE control_contrato = p_control_contrato;

    -- Cancelar adeudos pendientes
    UPDATE comun.ta_16_pagos
    SET status_vigencia = 'C'
    WHERE control_contrato = p_control_contrato
      AND status_vigencia = 'V';

    RETURN QUERY SELECT TRUE, 'Contrato dado de baja exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. SP_ASEO_CONTRATOS_BUSCAR - Buscar contratos
-- =====================================================
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_contratos_buscar(
    p_num_contrato INTEGER DEFAULT NULL,
    p_ctrol_aseo INTEGER DEFAULT NULL,
    p_num_empresa INTEGER DEFAULT NULL,
    p_domicilio VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    num_empresa INTEGER,
    nombre_empresa VARCHAR,
    domicilio VARCHAR,
    status_vigencia VARCHAR,
    monto_mensual NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        COALESCE(ta.tipo_aseo, '')::VARCHAR,
        c.num_empresa,
        COALESCE(e.descripcion, '')::VARCHAR,
        c.domicilio::VARCHAR,
        c.status_vigencia::VARCHAR,
        (COALESCE(u.costo_unidad, 0) * c.cantidad_recolec)::NUMERIC
    FROM comun.ta_16_contratos c
    LEFT JOIN aseo_contratado.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    LEFT JOIN aseo_contratado.ta_16_empresas e ON c.num_empresa = e.num_empresa
    LEFT JOIN comun.ta_16_unidades u ON c.ctrol_recolec = u.ctrol_recolec
        AND EXTRACT(YEAR FROM CURRENT_DATE) = u.ejercicio_recolec
    WHERE (p_num_contrato IS NULL OR c.num_contrato = p_num_contrato)
      AND (p_ctrol_aseo IS NULL OR c.ctrol_aseo = p_ctrol_aseo)
      AND (p_num_empresa IS NULL OR c.num_empresa = p_num_empresa)
      AND (p_domicilio IS NULL OR UPPER(c.domicilio) LIKE '%' || UPPER(p_domicilio) || '%')
    ORDER BY c.control_contrato DESC
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 7. SP_ASEO_ADEUDOS_VENCIDOS - Consultar adeudos vencidos
-- =====================================================
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_adeudos_vencidos(
    p_control_contrato INTEGER DEFAULT NULL,
    p_ctrol_aseo INTEGER DEFAULT NULL,
    p_fecha_corte DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    nombre_empresa VARCHAR,
    domicilio VARCHAR,
    aso_mes_pago DATE,
    periodo VARCHAR,
    ctrol_operacion INTEGER,
    descripcion_oper VARCHAR,
    importe NUMERIC,
    recargo NUMERIC,
    total NUMERIC,
    dias_vencido INTEGER
) AS $$
DECLARE
    v_dia_limite INTEGER;
    v_tasa_recargo NUMERIC;
BEGIN
    -- Obtener día límite del mes actual
    SELECT COALESCE(dia_limite, 15) INTO v_dia_limite
    FROM comun.ta_16_dia_limite
    WHERE mes = EXTRACT(MONTH FROM CURRENT_DATE)
    LIMIT 1;

    IF v_dia_limite IS NULL THEN
        v_dia_limite := 15;
    END IF;

    -- Obtener tasa de recargo
    SELECT COALESCE(tasa_recargo, 0.02) INTO v_tasa_recargo
    FROM aseo_contratado.ta_16_recargos
    WHERE ejercicio = EXTRACT(YEAR FROM CURRENT_DATE)
    LIMIT 1;

    IF v_tasa_recargo IS NULL THEN
        v_tasa_recargo := 0.02; -- 2% por default
    END IF;

    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        c.ctrol_aseo,
        COALESCE(ta.tipo_aseo, '')::VARCHAR,
        COALESCE(e.descripcion, '')::VARCHAR,
        c.domicilio::VARCHAR,
        p.aso_mes_pago::DATE,
        TO_CHAR(p.aso_mes_pago, 'MM/YYYY')::VARCHAR AS periodo,
        p.ctrol_operacion,
        CASE p.ctrol_operacion
            WHEN 6 THEN 'Cuota Normal'
            WHEN 7 THEN 'Excedencia'
            ELSE 'Otro'
        END::VARCHAR,
        p.importe,
        CASE
            WHEN p.aso_mes_pago < (p_fecha_corte - (v_dia_limite || ' days')::INTERVAL)::DATE
            THEN ROUND(p.importe * v_tasa_recargo *
                 GREATEST(1, EXTRACT(MONTH FROM AGE(p_fecha_corte, p.aso_mes_pago))::INTEGER), 2)
            ELSE 0
        END::NUMERIC AS recargo,
        (p.importe + CASE
            WHEN p.aso_mes_pago < (p_fecha_corte - (v_dia_limite || ' days')::INTERVAL)::DATE
            THEN ROUND(p.importe * v_tasa_recargo *
                 GREATEST(1, EXTRACT(MONTH FROM AGE(p_fecha_corte, p.aso_mes_pago))::INTEGER), 2)
            ELSE 0
        END)::NUMERIC AS total,
        (p_fecha_corte - p.aso_mes_pago)::INTEGER AS dias_vencido
    FROM comun.ta_16_pagos p
    JOIN comun.ta_16_contratos c ON p.control_contrato = c.control_contrato
    LEFT JOIN aseo_contratado.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    LEFT JOIN aseo_contratado.ta_16_empresas e ON c.num_empresa = e.num_empresa
    WHERE p.status_vigencia = 'V'
      AND p.aso_mes_pago <= p_fecha_corte
      AND (p_control_contrato IS NULL OR c.control_contrato = p_control_contrato)
      AND (p_ctrol_aseo IS NULL OR c.ctrol_aseo = p_ctrol_aseo)
    ORDER BY c.control_contrato, p.aso_mes_pago;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 8. SP_ASEO_PAGO_REGISTRAR - Registrar pago
-- =====================================================
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_pago_registrar(
    p_control_contrato INTEGER,
    p_aso_mes_pago DATE,
    p_ctrol_operacion INTEGER,
    p_importe NUMERIC,
    p_id_rec SMALLINT,
    p_caja VARCHAR,
    p_consec_operacion INTEGER,
    p_folio_rcbo VARCHAR,
    p_usuario INTEGER DEFAULT 0
)
RETURNS TABLE(success BOOLEAN, message VARCHAR) AS $$
BEGIN
    -- Actualizar el pago a Pagado
    UPDATE comun.ta_16_pagos
    SET
        status_vigencia = 'P',
        fecha_hora_pago = NOW(),
        id_rec = p_id_rec,
        caja = p_caja,
        consec_operacion = p_consec_operacion,
        folio_rcbo = p_folio_rcbo,
        usuario = p_usuario
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago = p_aso_mes_pago
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No se encontró el adeudo para pagar'::VARCHAR;
        RETURN;
    END IF;

    RETURN QUERY SELECT TRUE, 'Pago registrado exitosamente'::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 9. SP_ASEO_CATALOGOS - SPs para catálogos ABC
-- =====================================================

-- Tipos de Aseo
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_tipos_aseo_list()
RETURNS TABLE(ctrol_aseo INTEGER, tipo_aseo VARCHAR, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT t.ctrol_aseo, t.tipo_aseo::VARCHAR, t.descripcion::VARCHAR
    FROM aseo_contratado.ta_16_tipo_aseo t
    ORDER BY t.ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- Empresas
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_empresas_list()
RETURNS TABLE(num_empresa INTEGER, ctrol_emp INTEGER, descripcion VARCHAR, representante VARCHAR, tipo_empresa VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT e.num_empresa, e.ctrol_emp, e.descripcion::VARCHAR, e.representante::VARCHAR,
           COALESCE(te.descripcion, '')::VARCHAR AS tipo_empresa
    FROM aseo_contratado.ta_16_empresas e
    LEFT JOIN aseo_contratado.ta_16_tipos_emp te ON e.ctrol_emp = te.ctrol_emp
    ORDER BY e.num_empresa;
END;
$$ LANGUAGE plpgsql;

-- Zonas
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_zonas_list()
RETURNS TABLE(ctrol_zona INTEGER, zona SMALLINT, sub_zona SMALLINT, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT z.ctrol_zona, z.zona, z.sub_zona, z.descripcion::VARCHAR
    FROM aseo_contratado.ta_16_zonas z
    ORDER BY z.ctrol_zona;
END;
$$ LANGUAGE plpgsql;

-- Unidades de Recolección
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_unidades_list(p_ejercicio INTEGER DEFAULT NULL)
RETURNS TABLE(ctrol_recolec INTEGER, ejercicio_recolec SMALLINT, cve_recolec VARCHAR, descripcion VARCHAR, costo_unidad NUMERIC, costo_exed NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT u.ctrol_recolec, u.ejercicio_recolec, u.cve_recolec::VARCHAR, u.descripcion::VARCHAR, u.costo_unidad, u.costo_exed
    FROM comun.ta_16_unidades u
    WHERE (p_ejercicio IS NULL OR u.ejercicio_recolec = p_ejercicio)
    ORDER BY u.ejercicio_recolec DESC, u.ctrol_recolec;
END;
$$ LANGUAGE plpgsql;

-- Recaudadoras
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_recaudadoras_list()
RETURNS TABLE(id_rec SMALLINT, recaudadora VARCHAR, domicilio VARCHAR, recaudador VARCHAR, sector VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT r.id_rec, r.recaudadora::VARCHAR, r.domicilio::VARCHAR, r.recaudador::VARCHAR, r.sector::VARCHAR
    FROM comun.ta_12_recaudadoras r
    ORDER BY r.id_rec;
END;
$$ LANGUAGE plpgsql;

-- Recargos
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_recargos_list()
RETURNS TABLE(ejercicio INTEGER, tasa_recargo NUMERIC, tasa_actualizacion NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT r.ejercicio::INTEGER, r.tasa_recargo, r.tasa_actualizacion
    FROM aseo_contratado.ta_16_recargos r
    ORDER BY r.ejercicio DESC;
END;
$$ LANGUAGE plpgsql;

-- Gastos
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_gastos_list()
RETURNS TABLE(cve_gasto INTEGER, descripcion VARCHAR, importe NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT g.cve_gasto, g.descripcion::VARCHAR, g.importe
    FROM aseo_contratado.ta_16_gastos g
    ORDER BY g.cve_gasto;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 10. SP_ASEO_ESTADO_CUENTA - Estado de cuenta
-- =====================================================
CREATE OR REPLACE FUNCTION aseo_contratado.sp_aseo_estado_cuenta(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    num_contrato INTEGER,
    tipo_aseo VARCHAR,
    nombre_empresa VARCHAR,
    domicilio VARCHAR,
    periodo VARCHAR,
    concepto VARCHAR,
    importe NUMERIC,
    recargo NUMERIC,
    total NUMERIC,
    status VARCHAR,
    fecha_pago TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.control_contrato,
        c.num_contrato,
        COALESCE(ta.tipo_aseo, '')::VARCHAR,
        COALESCE(e.descripcion, '')::VARCHAR,
        c.domicilio::VARCHAR,
        TO_CHAR(p.aso_mes_pago, 'MM/YYYY')::VARCHAR,
        CASE p.ctrol_operacion
            WHEN 6 THEN 'Cuota Normal'
            WHEN 7 THEN 'Excedencia'
            ELSE 'Otro'
        END::VARCHAR,
        p.importe,
        0::NUMERIC AS recargo, -- Calcular según reglas
        p.importe AS total,
        CASE p.status_vigencia
            WHEN 'V' THEN 'Pendiente'
            WHEN 'P' THEN 'Pagado'
            WHEN 'C' THEN 'Cancelado'
            ELSE p.status_vigencia
        END::VARCHAR,
        p.fecha_hora_pago
    FROM comun.ta_16_pagos p
    JOIN comun.ta_16_contratos c ON p.control_contrato = c.control_contrato
    LEFT JOIN aseo_contratado.ta_16_tipo_aseo ta ON c.ctrol_aseo = ta.ctrol_aseo
    LEFT JOIN aseo_contratado.ta_16_empresas e ON c.num_empresa = e.num_empresa
    WHERE c.control_contrato = p_control_contrato
    ORDER BY p.aso_mes_pago, p.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Mensaje de éxito
-- =====================================================
DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'SPs de Aseo Contratado creados exitosamente';
    RAISE NOTICE 'Total: 15 Stored Procedures';
    RAISE NOTICE '========================================';
END $$;
