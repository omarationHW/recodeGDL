-- ============================================================================
-- MÓDULO PAGOS - 7 SPs
-- Generado: 2025-11-09
-- Desbloquea: Pagos_Cons_Cont.vue, Pagos_Con_FPgo.vue, etc.
-- ============================================================================

-- 1. SP_ASEO_PAGOS_BUSCAR - Buscar pagos por criterios
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_buscar(
    p_control_contrato INTEGER DEFAULT NULL,
    p_folio_rcbo VARCHAR DEFAULT NULL,
    p_fecha_desde TIMESTAMP DEFAULT NULL,
    p_fecha_hasta TIMESTAMP DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    control_contrato INTEGER,
    aso_mes_pago TIMESTAMP,
    ctrol_operacion INTEGER,
    importe NUMERIC,
    fecha_hora_pago TIMESTAMP,
    folio_rcbo VARCHAR,
    caja VARCHAR,
    status_vigencia CHAR,
    observaciones VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.control_contrato,
        p.aso_mes_pago,
        p.ctrol_operacion,
        p.importe,
        p.fecha_hora_pago,
        p.folio_rcbo,
        p.caja::VARCHAR,
        p.status_vigencia,
        p.observaciones
    FROM ta_16_pagos p
    WHERE (p_control_contrato IS NULL OR p.control_contrato = p_control_contrato)
      AND (p_folio_rcbo IS NULL OR p.folio_rcbo ILIKE '%' || p_folio_rcbo || '%')
      AND (p_fecha_desde IS NULL OR p.fecha_hora_pago >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR p.fecha_hora_pago <= p_fecha_hasta)
      AND p.status_vigencia = 'V'
    ORDER BY p.fecha_hora_pago DESC
    LIMIT p_limit;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 2. SP_ASEO_PAGOS_ACTUALIZAR_PERIODOS - Actualizar periodos de pagos
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_actualizar_periodos(
    p_control_contrato INTEGER,
    p_aso_mes_anterior TIMESTAMP,
    p_aso_mes_nuevo TIMESTAMP
)
RETURNS TABLE(success BOOLEAN, message TEXT, total_updated INTEGER) AS $function$
DECLARE
    v_updated INTEGER;
BEGIN
    UPDATE ta_16_pagos
    SET aso_mes_pago = p_aso_mes_nuevo
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago = p_aso_mes_anterior
      AND status_vigencia = 'V';

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    IF v_updated > 0 THEN
        RETURN QUERY SELECT TRUE, 'Periodos actualizados correctamente', v_updated;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se encontraron pagos para actualizar', 0;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0;
END;
$function$ LANGUAGE plpgsql;

-- 3. SP_ASEO_PAGOS_HISTORIAL_ACTUALIZACIONES - Historial de actualizaciones de pagos
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_historial_actualizaciones(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    aso_mes_pago TIMESTAMP,
    importe NUMERIC,
    fecha_hora_pago TIMESTAMP,
    folio_rcbo VARCHAR,
    usuario INTEGER,
    status_vigencia CHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.aso_mes_pago,
        p.importe,
        p.fecha_hora_pago,
        p.folio_rcbo,
        p.usuario,
        p.status_vigencia
    FROM ta_16_pagos p
    WHERE p.control_contrato = p_control_contrato
    ORDER BY p.fecha_hora_pago DESC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 4. SP_ASEO_PAGOS_POR_CONTRATO - Consultar pagos por contrato
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_por_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    aso_mes_pago TIMESTAMP,
    ctrol_operacion INTEGER,
    importe NUMERIC,
    status_vigencia CHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR,
    usuario INTEGER,
    exedencias SMALLINT,
    observaciones VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.control_contrato,
        p.aso_mes_pago,
        p.ctrol_operacion,
        p.importe,
        p.status_vigencia,
        p.fecha_hora_pago,
        p.id_rec,
        p.caja::VARCHAR,
        p.consec_operacion,
        p.folio_rcbo,
        p.usuario,
        p.exedencias,
        p.observaciones
    FROM ta_16_pagos p
    WHERE p.control_contrato = p_control_contrato
      AND p.status_vigencia = 'V'
    ORDER BY p.fecha_hora_pago DESC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 5. SP_ASEO_PAGOS_POR_FORMA_PAGO - Consultar pagos agrupados por forma de pago
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_por_forma_pago(
    p_fecha_desde TIMESTAMP DEFAULT NULL,
    p_fecha_hasta TIMESTAMP DEFAULT NULL
)
RETURNS TABLE(
    id_rec SMALLINT,
    forma_pago VARCHAR,
    total_pagos BIGINT,
    total_importe NUMERIC
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.id_rec,
        CASE p.id_rec
            WHEN 1 THEN 'Efectivo'
            WHEN 2 THEN 'Tarjeta'
            WHEN 3 THEN 'Transferencia'
            ELSE 'Otro'
        END as forma_pago,
        COUNT(*)::BIGINT as total_pagos,
        SUM(p.importe) as total_importe
    FROM ta_16_pagos p
    WHERE p.status_vigencia = 'V'
      AND (p_fecha_desde IS NULL OR p.fecha_hora_pago >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR p.fecha_hora_pago <= p_fecha_hasta)
    GROUP BY p.id_rec
    ORDER BY total_importe DESC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 6. SP_ASEO_PAGOS_POR_CONTRATO_ASC - Consultar pagos por contrato ordenados ascendente
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_por_contrato_asc(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    aso_mes_pago TIMESTAMP,
    ctrol_operacion INTEGER,
    importe NUMERIC,
    status_vigencia CHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR,
    usuario INTEGER,
    exedencias SMALLINT,
    observaciones VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.control_contrato,
        p.aso_mes_pago,
        p.ctrol_operacion,
        p.importe,
        p.status_vigencia,
        p.fecha_hora_pago,
        p.id_rec,
        p.caja::VARCHAR,
        p.consec_operacion,
        p.folio_rcbo,
        p.usuario,
        p.exedencias,
        p.observaciones
    FROM ta_16_pagos p
    WHERE p.control_contrato = p_control_contrato
      AND p.status_vigencia = 'V'
    ORDER BY p.fecha_hora_pago ASC;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- 7. SP_ASEO_PAGOS_BY_CONTRATO - Alias de SP_ASEO_PAGOS_POR_CONTRATO (para compatibilidad)
CREATE OR REPLACE FUNCTION public.sp_aseo_pagos_by_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE(
    control_contrato INTEGER,
    aso_mes_pago TIMESTAMP,
    ctrol_operacion INTEGER,
    importe NUMERIC,
    status_vigencia CHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR,
    usuario INTEGER,
    exedencias SMALLINT,
    observaciones VARCHAR
) AS $function$
BEGIN
    RETURN QUERY
    SELECT * FROM sp_aseo_pagos_por_contrato(p_control_contrato);
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Error: %', SQLERRM;
    RETURN;
END;
$function$ LANGUAGE plpgsql;

-- ============================================================================
-- FIN MÓDULO PAGOS
-- ============================================================================
