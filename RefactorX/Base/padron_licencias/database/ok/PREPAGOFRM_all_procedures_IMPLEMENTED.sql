-- ============================================================================
-- MÓDULO: PADRON_LICENCIAS
-- COMPONENTE: PREPAGOFRM
-- DESCRIPCIÓN: Gestión de prepagos de predial con descuentos y liquidaciones
-- TOTAL STORED PROCEDURES: 6
-- SCHEMA: comun
-- GENERADO: 2025-11-20
-- ============================================================================

-- ============================================================================
-- SP 1/6: sp_prepago_get_data
-- DESCRIPCIÓN: Obtiene los datos principales del contribuyente y cuenta
--              catastral para el formulario de prepago
-- TIPO: CONSULTA
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_prepago_get_data(
    p_cvecuenta INTEGER
)
RETURNS TABLE(
    ncompleto TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    ultcomp INTEGER,
    axoultcomp SMALLINT,
    saldo_actual NUMERIC(12,2),
    puede_prepagar BOOLEAN,
    anio_actual INTEGER
) AS $$
BEGIN
    -- Validación de entrada
    IF p_cvecuenta IS NULL OR p_cvecuenta <= 0 THEN
        RAISE EXCEPTION 'Parámetro p_cvecuenta inválido: %', p_cvecuenta;
    END IF;

    RETURN QUERY
    SELECT
        c.nombre_completo::TEXT,
        c.calle::TEXT,
        c.noexterior::TEXT,
        c.interior::TEXT,
        ca.ultcomp,
        ca.axoultcomp,
        COALESCE(s.saldo, 0)::NUMERIC(12,2) as saldo_actual,
        CASE
            WHEN COALESCE(s.saldo, 0) > 0 THEN TRUE
            ELSE FALSE
        END as puede_prepagar,
        EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER as anio_actual
    FROM catastro ca
    JOIN regprop rp ON rp.cvecuenta = ca.cvecuenta
                   AND rp.cveregprop = ca.cveregprop
                   AND rp.encabeza = 'S'
    JOIN contrib c ON c.cvecont = rp.cvecont
    LEFT JOIN saldos s ON s.cvecuenta = ca.cvecuenta
    WHERE ca.cvecuenta = p_cvecuenta
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_prepago_get_data(INTEGER) IS
'Obtiene datos del contribuyente y cuenta catastral para prepago predial';

-- ============================================================================
-- SP 2/6: sp_prepago_calcular_descpred
-- DESCRIPCIÓN: Calcula el descuento predial por pronto pago aplicando
--              reglas de negocio (típicamente 15% sobre saldo)
-- TIPO: CÁLCULO
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_prepago_calcular_descpred(
    p_cvecuenta INTEGER,
    p_porcentaje_descuento NUMERIC(5,2) DEFAULT 15.00
)
RETURNS TABLE(
    cvecuenta INTEGER,
    saldo_original NUMERIC(12,2),
    porcentaje_descuento NUMERIC(5,2),
    importe_descuento NUMERIC(12,2),
    saldo_con_descuento NUMERIC(12,2),
    fecha_calculo TIMESTAMP,
    puede_aplicar BOOLEAN,
    mensaje TEXT
) AS $$
DECLARE
    v_saldo NUMERIC(12,2);
    v_descuento_max NUMERIC(5,2) := 20.00; -- Descuento máximo permitido
    v_puede_aplicar BOOLEAN;
    v_mensaje TEXT;
BEGIN
    -- Validaciones
    IF p_cvecuenta IS NULL OR p_cvecuenta <= 0 THEN
        RAISE EXCEPTION 'Parámetro p_cvecuenta inválido: %', p_cvecuenta;
    END IF;

    IF p_porcentaje_descuento < 0 OR p_porcentaje_descuento > v_descuento_max THEN
        RAISE EXCEPTION 'Porcentaje de descuento inválido: %. Debe estar entre 0 y %',
                        p_porcentaje_descuento, v_descuento_max;
    END IF;

    -- Obtener saldo actual
    SELECT COALESCE(s.saldo, 0) INTO v_saldo
    FROM saldos s
    WHERE s.cvecuenta = p_cvecuenta;

    -- Determinar si puede aplicar descuento
    IF v_saldo > 0 THEN
        v_puede_aplicar := TRUE;
        v_mensaje := 'Descuento calculado correctamente';
    ELSE
        v_puede_aplicar := FALSE;
        v_mensaje := 'No hay saldo para aplicar descuento';
    END IF;

    RETURN QUERY
    SELECT
        p_cvecuenta,
        v_saldo,
        p_porcentaje_descuento,
        ROUND(v_saldo * (p_porcentaje_descuento / 100), 2)::NUMERIC(12,2) as importe_descuento,
        ROUND(v_saldo * (1 - p_porcentaje_descuento / 100), 2)::NUMERIC(12,2) as saldo_con_descuento,
        CURRENT_TIMESTAMP,
        v_puede_aplicar,
        v_mensaje;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_prepago_calcular_descpred(INTEGER, NUMERIC) IS
'Calcula descuento predial por pronto pago (default 15%)';

-- ============================================================================
-- SP 3/6: sp_prepago_get_ultimo_requerimiento
-- DESCRIPCIÓN: Obtiene el último requerimiento practicado para la cuenta
-- TIPO: CONSULTA
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_prepago_get_ultimo_requerimiento(
    p_cvecuenta INTEGER
)
RETURNS TABLE(
    cvereq INTEGER,
    cveejecut SMALLINT,
    folioreq INTEGER,
    axoreq SMALLINT,
    cvecuenta INTEGER,
    cvepago INTEGER,
    impuesto NUMERIC(12,2),
    recargos NUMERIC(12,2),
    gastos NUMERIC(12,2),
    multas NUMERIC(12,2),
    total NUMERIC(12,2),
    fecemi DATE,
    fecent DATE,
    cvecancr TEXT,
    axoini SMALLINT,
    bimini SMALLINT,
    axofin SMALLINT,
    bimfin SMALLINT,
    secuencia SMALLINT,
    vigencia TEXT,
    feccap DATE,
    capturista TEXT,
    iniper TEXT,
    finper TEXT,
    diastrans INTEGER
) AS $$
BEGIN
    -- Validación
    IF p_cvecuenta IS NULL OR p_cvecuenta <= 0 THEN
        RAISE EXCEPTION 'Parámetro p_cvecuenta inválido: %', p_cvecuenta;
    END IF;

    RETURN QUERY
    SELECT
        r.cvereq,
        r.cveejecut,
        r.folioreq,
        r.axoreq,
        r.cvecuenta,
        r.cvepago,
        r.impuesto::NUMERIC(12,2),
        r.recargos::NUMERIC(12,2),
        r.gastos::NUMERIC(12,2),
        r.multas::NUMERIC(12,2),
        r.total::NUMERIC(12,2),
        r.fecemi,
        r.fecent,
        r.cvecancr,
        r.axoini,
        r.bimini,
        r.axofin,
        r.bimfin,
        r.secuencia,
        r.vigencia,
        r.feccap,
        r.capturista,
        (r.bimini::TEXT || '/' || r.axoini::TEXT)::TEXT as iniper,
        (r.bimfin::TEXT || '/' || r.axofin::TEXT)::TEXT as finper,
        (CURRENT_DATE - r.fecent)::INTEGER as diastrans
    FROM reqpredial r
    WHERE r.cvecuenta = p_cvecuenta
      AND r.vigencia = 'V'
      AND r.fecent IS NOT NULL
    ORDER BY r.axoreq DESC, r.folioreq DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_prepago_get_ultimo_requerimiento(INTEGER) IS
'Obtiene el último requerimiento vigente practicado para la cuenta';

-- ============================================================================
-- SP 4/6: sp_prepago_recalcular_dpp
-- DESCRIPCIÓN: Recalcula el detalle de descuento por pronto pago (DPP)
--              actualizando saldos y descuentos en detsaldos
-- TIPO: ACTUALIZACIÓN
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_prepago_recalcular_dpp(
    p_cvecuenta INTEGER,
    p_porcentaje_descuento NUMERIC(5,2) DEFAULT 15.00,
    p_usuario VARCHAR(50) DEFAULT 'SISTEMA'
)
RETURNS TABLE(
    success BOOLEAN,
    mensaje TEXT,
    registros_actualizados INTEGER,
    importe_descuento_total NUMERIC(12,2)
) AS $$
DECLARE
    v_registros INTEGER := 0;
    v_total_descuento NUMERIC(12,2) := 0;
    v_mensaje TEXT;
BEGIN
    -- Validaciones
    IF p_cvecuenta IS NULL OR p_cvecuenta <= 0 THEN
        RAISE EXCEPTION 'Parámetro p_cvecuenta inválido: %', p_cvecuenta;
    END IF;

    IF p_porcentaje_descuento < 0 OR p_porcentaje_descuento > 20 THEN
        RAISE EXCEPTION 'Porcentaje de descuento inválido: %. Debe estar entre 0 y 20',
                        p_porcentaje_descuento;
    END IF;

    -- Recalcular descuentos en detsaldos
    -- Actualizar el campo impvir (importe virtual/descuento)
    WITH actualizacion AS (
        UPDATE detsaldos
        SET
            impvir = ROUND((impade + impfac) * (p_porcentaje_descuento / 100), 2),
            fecmov = CURRENT_DATE,
            usuario = p_usuario
        WHERE cvecuenta = p_cvecuenta
          AND saldo > 0
          AND cvedescuento IS NULL -- Solo actualizar si no tiene descuento específico
        RETURNING cvecuenta, impvir
    )
    SELECT
        COUNT(*)::INTEGER,
        COALESCE(SUM(impvir), 0)::NUMERIC(12,2)
    INTO v_registros, v_total_descuento
    FROM actualizacion;

    -- Actualizar tabla de saldos con el nuevo descuento
    IF v_registros > 0 THEN
        UPDATE saldos
        SET
            multavir = v_total_descuento,
            fecmov = CURRENT_DATE
        WHERE cvecuenta = p_cvecuenta;

        v_mensaje := 'Descuento recalculado correctamente';
    ELSE
        v_mensaje := 'No se encontraron registros para recalcular';
    END IF;

    RETURN QUERY
    SELECT
        TRUE,
        v_mensaje,
        v_registros,
        v_total_descuento;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            'Error al recalcular DPP: ' || SQLERRM,
            0,
            0::NUMERIC(12,2);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_prepago_recalcular_dpp(INTEGER, NUMERIC, VARCHAR) IS
'Recalcula el detalle de descuento por pronto pago para la cuenta';

-- ============================================================================
-- SP 5/6: sp_prepago_liquidacion_parcial
-- DESCRIPCIÓN: Calcula la liquidación parcial de adeudo predial hasta
--              un año/bimestre dado
-- TIPO: CONSULTA/CÁLCULO
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_prepago_liquidacion_parcial(
    p_cvecuenta INTEGER,
    p_asalf INTEGER,  -- Año hasta el que se liquida
    p_bsalf INTEGER   -- Bimestre hasta el que se liquida
)
RETURNS JSON AS $$
DECLARE
    v_detalle JSON;
    v_totales JSON;
    v_anio_inicial INTEGER := 1900;
    v_bim_inicial INTEGER := 1;
BEGIN
    -- Validaciones
    IF p_cvecuenta IS NULL OR p_cvecuenta <= 0 THEN
        RAISE EXCEPTION 'Parámetro p_cvecuenta inválido: %', p_cvecuenta;
    END IF;

    IF p_asalf IS NULL OR p_asalf < v_anio_inicial THEN
        RAISE EXCEPTION 'Parámetro p_asalf inválido: %. Debe ser >= %', p_asalf, v_anio_inicial;
    END IF;

    IF p_bsalf IS NULL OR p_bsalf < 1 OR p_bsalf > 6 THEN
        RAISE EXCEPTION 'Parámetro p_bsalf inválido: %. Debe estar entre 1 y 6', p_bsalf;
    END IF;

    -- Detalle de bimestres
    SELECT json_agg(row_to_json(t)) INTO v_detalle
    FROM (
        SELECT
            v.axoefec,
            v.valfiscal::NUMERIC(12,2),
            v.tasa::NUMERIC(5,2),
            v.axosobre,
            SUM(d.recvir)::NUMERIC(12,2) AS recvir,
            SUM(d.impade + d.impvir)::NUMERIC(12,2) AS impfac,
            SUM(d.impvir)::NUMERIC(12,2) AS impvir,
            SUM(d.impade)::NUMERIC(12,2) AS impade,
            SUM(d.recfac - d.recpag - d.recvir)::NUMERIC(12,2) AS total,
            MIN(v.bimefec)::SMALLINT AS bimini,
            MAX(v.bimefec)::SMALLINT AS bimfin,
            (MIN(v.bimefec)::TEXT || '/' || v.axoefec::TEXT) AS inicio,
            (MAX(v.bimefec)::TEXT || '/' || v.axoefec::TEXT) AS fin
        FROM detsaldos d
        JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta
                          AND v.axoefec = d.axosal
                          AND v.bimefec = d.bimsal
        WHERE d.cvecuenta = p_cvecuenta
          AND d.saldo > 0
          AND ((d.axosal > v_anio_inicial OR (d.bimsal >= v_bim_inicial AND d.axosal = v_anio_inicial))
               AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
        GROUP BY v.axoefec, v.valfiscal, v.tasa, v.axosobre
        ORDER BY v.axoefec, bimini
    ) t;

    -- Totales generales
    SELECT row_to_json(t) INTO v_totales
    FROM (
        SELECT
            SUM(d.recfac - d.recpag - d.recvir)::NUMERIC(12,2) AS recppag,
            SUM(d.impfac - d.imppag - d.impvir)::NUMERIC(12,2) AS impppag,
            (s.multa - s.multavir)::NUMERIC(12,2) AS multa,
            s.multavir::NUMERIC(12,2),
            s.gasto::NUMERIC(12,2),
            s.axotope,
            s.desctope::NUMERIC(12,2),
            s.desctoppp::NUMERIC(12,2),
            (SUM(d.recfac - d.recpag - d.recvir) +
             (s.multa - s.multavir) +
             s.gasto -
             s.desctope -
             s.desctoppp)::NUMERIC(12,2) AS total_general
        FROM detsaldos d
        JOIN saldos s ON s.cvecuenta = d.cvecuenta
        WHERE d.cvecuenta = p_cvecuenta
          AND d.saldo > 0
          AND ((d.axosal > v_anio_inicial OR (d.bimsal >= v_bim_inicial AND d.axosal = v_anio_inicial))
               AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
        GROUP BY s.multa, s.multavir, s.gasto, s.axotope, s.desctope, s.desctoppp
        LIMIT 1
    ) t;

    -- Retornar resultado consolidado
    RETURN json_build_object(
        'success', true,
        'cvecuenta', p_cvecuenta,
        'periodo_hasta', p_bsalf::TEXT || '/' || p_asalf::TEXT,
        'detalle', COALESCE(v_detalle, '[]'::JSON),
        'totales', COALESCE(v_totales, '{}'::JSON),
        'fecha_calculo', CURRENT_TIMESTAMP
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN json_build_object(
            'success', false,
            'error', SQLERRM,
            'detalle', '[]'::JSON,
            'totales', '{}'::JSON
        );
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_prepago_liquidacion_parcial(INTEGER, INTEGER, INTEGER) IS
'Calcula liquidación parcial de adeudo predial hasta año/bimestre especificado';

-- ============================================================================
-- SP 6/6: sp_prepago_eliminar_dpp
-- DESCRIPCIÓN: Elimina el descuento por pronto pago (DPP) de la cuenta
--              restaurando valores originales
-- TIPO: ELIMINACIÓN/ACTUALIZACIÓN
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_prepago_eliminar_dpp(
    p_cvecuenta INTEGER,
    p_usuario VARCHAR(50) DEFAULT 'SISTEMA',
    p_motivo TEXT DEFAULT 'Eliminación de descuento por pronto pago'
)
RETURNS TABLE(
    success BOOLEAN,
    mensaje TEXT,
    registros_afectados INTEGER,
    descuento_eliminado NUMERIC(12,2)
) AS $$
DECLARE
    v_registros INTEGER := 0;
    v_descuento_eliminado NUMERIC(12,2) := 0;
    v_mensaje TEXT;
BEGIN
    -- Validaciones
    IF p_cvecuenta IS NULL OR p_cvecuenta <= 0 THEN
        RAISE EXCEPTION 'Parámetro p_cvecuenta inválido: %', p_cvecuenta;
    END IF;

    -- Obtener total de descuentos antes de eliminar
    SELECT COALESCE(SUM(impvir), 0)::NUMERIC(12,2)
    INTO v_descuento_eliminado
    FROM detsaldos
    WHERE cvecuenta = p_cvecuenta
      AND impvir > 0
      AND saldo > 0;

    -- Eliminar descuentos en detsaldos
    -- Establecer impvir en 0 y limpiar cvedescuento
    WITH eliminacion AS (
        UPDATE detsaldos
        SET
            impvir = 0,
            recvir = 0,
            cvedescuento = NULL,
            fecmov = CURRENT_DATE,
            usuario = p_usuario
        WHERE cvecuenta = p_cvecuenta
          AND saldo > 0
          AND impvir > 0
        RETURNING cvecuenta
    )
    SELECT COUNT(*)::INTEGER
    INTO v_registros
    FROM eliminacion;

    -- Actualizar saldos
    IF v_registros > 0 THEN
        UPDATE saldos
        SET
            multavir = 0,
            desctope = 0,
            desctoppp = 0,
            fecmov = CURRENT_DATE
        WHERE cvecuenta = p_cvecuenta;

        -- Registrar en bitácora (si existe tabla de auditoría)
        BEGIN
            INSERT INTO auditoria_prepago (
                cvecuenta,
                accion,
                usuario,
                motivo,
                importe,
                fecha
            )
            VALUES (
                p_cvecuenta,
                'ELIMINAR_DPP',
                p_usuario,
                p_motivo,
                v_descuento_eliminado,
                CURRENT_TIMESTAMP
            );
        EXCEPTION
            WHEN undefined_table THEN
                -- Si no existe tabla de auditoría, continuar sin error
                NULL;
        END;

        v_mensaje := 'Descuento eliminado correctamente';
    ELSE
        v_mensaje := 'No se encontraron descuentos para eliminar';
    END IF;

    RETURN QUERY
    SELECT
        TRUE,
        v_mensaje,
        v_registros,
        v_descuento_eliminado;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY
        SELECT
            FALSE,
            'Error al eliminar DPP: ' || SQLERRM,
            0,
            0::NUMERIC(12,2);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_prepago_eliminar_dpp(INTEGER, VARCHAR, TEXT) IS
'Elimina el descuento por pronto pago restaurando valores originales';

-- ============================================================================
-- FUNCIÓN AUXILIAR: sp_prepago_get_descuentos
-- DESCRIPCIÓN: Obtiene los descuentos aplicados a la cuenta en periodo
-- TIPO: CONSULTA
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.sp_prepago_get_descuentos(
    p_cvecuenta INTEGER,
    p_asal INTEGER,      -- Año desde
    p_bsal INTEGER,      -- Bimestre desde
    p_asalf INTEGER,     -- Año hasta
    p_bsalf INTEGER      -- Bimestre hasta
)
RETURNS TABLE(
    cvedescuento INTEGER,
    descripcion TEXT,
    impdescto NUMERIC(12,2),
    num_bimestres INTEGER
) AS $$
BEGIN
    -- Validaciones
    IF p_cvecuenta IS NULL OR p_cvecuenta <= 0 THEN
        RAISE EXCEPTION 'Parámetro p_cvecuenta inválido: %', p_cvecuenta;
    END IF;

    RETURN QUERY
    SELECT
        d.cvedescuento,
        COALESCE(c.descripcion, 'Sin descripción')::TEXT,
        SUM(d.impvir)::NUMERIC(12,2) AS impdescto,
        COUNT(DISTINCT (d.axosal::TEXT || '-' || d.bimsal::TEXT))::INTEGER as num_bimestres
    FROM detsaldos d
    JOIN valoradeudo v ON v.cvecuenta = d.cvecuenta
                      AND v.axoefec = d.axosal
                      AND v.bimefec = d.bimsal
    LEFT JOIN c_descpred c ON d.cvedescuento = c.cvedescuento
    WHERE d.cvecuenta = p_cvecuenta
      AND d.saldo > 0
      AND ((d.axosal > p_asal OR (d.bimsal >= p_bsal AND d.axosal = p_asal))
           AND (d.axosal < p_asalf OR (d.bimsal <= p_bsalf AND d.axosal = p_asalf)))
      AND d.cvedescuento IS NOT NULL
    GROUP BY d.cvedescuento, c.descripcion
    ORDER BY d.cvedescuento;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_prepago_get_descuentos(INTEGER, INTEGER, INTEGER, INTEGER, INTEGER) IS
'Obtiene descuentos aplicados a la cuenta en el periodo especificado';

-- ============================================================================
-- FIN DE STORED PROCEDURES - PREPAGOFRM
-- Total implementados: 7 (6 principales + 1 auxiliar)
-- Schema: comun
-- ============================================================================
