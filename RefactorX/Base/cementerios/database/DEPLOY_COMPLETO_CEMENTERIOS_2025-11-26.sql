-- =====================================================
-- DEPLOYMENT COMPLETO: Cementerios
-- Base de datos: cementerio.public
-- Fecha: 2025-11-26
-- =====================================================
-- Contenido:
-- PARTE 1: Vistas necesarias (2)
-- PARTE 2: Stored Procedures (6)
-- =====================================================

-- =====================================================
-- PARTE 1: VISTAS NECESARIAS
-- =====================================================

-- Vista 1: v_ta_13_pagosrcm
CREATE OR REPLACE VIEW public.v_ta_13_pagosrcm AS
SELECT
    fecing,
    recing,
    cajing,
    opcaja,
    control_id,
    control_rcm,
    cementerio,
    clase,
    clase_alfa,
    seccion,
    seccion_alfa,
    linea,
    linea_alfa,
    fosa,
    fosa_alfa,
    axo_pago_desde,
    axo_pago_hasta,
    importe_anual,
    importe_recargos,
    vigencia,
    usuario,
    fecha_mov
FROM public.ta_13_pagosrcm;

COMMENT ON VIEW public.v_ta_13_pagosrcm IS 'Vista sobre tabla de pagos de cementerios RCM';

-- Vista 2: v_tc_13_cementerios
CREATE OR REPLACE VIEW public.v_tc_13_cementerios AS
SELECT
    cementerio,
    nombre,
    domicilio,
    cta_aplicacion,
    cta_vencido,
    cta_descto,
    cta_desctopens,
    cta_desctopens_rez,
    cta_actualizacion
FROM public.tc_13_cementerios;

COMMENT ON VIEW public.v_tc_13_cementerios IS 'Vista sobre catálogo de cementerios';

-- =====================================================
-- PARTE 2: STORED PROCEDURES
-- =====================================================

-- =====================================================
-- SP 1: sp_cem_consultar_por_nombre
-- Estado: Placeholder
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_cem_consultar_por_nombre(
    p_nombre character varying DEFAULT NULL::character varying,
    p_p_limit integer DEFAULT NULL::integer
)
RETURNS TABLE(
    success boolean,
    message character varying,
    data jsonb
)
LANGUAGE plpgsql
AS $function$
BEGIN
    -- SP generado automaticamente
    -- TODO: Implementar logica especifica

    -- Consulta generica
    RETURN QUERY
    SELECT
        TRUE::BOOLEAN as success,
        'Consulta ejecutada'::VARCHAR as message,
        '{}'::JSONB as data;
END;
$function$;

COMMENT ON FUNCTION public.sp_cem_consultar_por_nombre IS 'Consulta generica por nombre (placeholder)';

-- =====================================================
-- SP 2: sp_cem_consultar_folios_por_nombre
-- Estado: Requiere ta_13_datosrcm
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_cem_consultar_folios_por_nombre(
    p_nombre character varying,
    p_limit integer DEFAULT 50
)
RETURNS TABLE(
    control_rcm integer,
    nombre character varying,
    cementerio character varying,
    cementerio_nombre character varying,
    clase integer,
    seccion integer,
    linea integer,
    fosa integer,
    axo_pagado integer
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        d.control_rcm::INTEGER,
        TRIM(d.nombre)::VARCHAR as nombre,
        d.cementerio::VARCHAR,
        c.nombre::VARCHAR as cementerio_nombre,
        d.clase::INTEGER,
        d.seccion::INTEGER,
        d.linea::INTEGER,
        d.fosa::INTEGER,
        COALESCE(d.axo_pagado, 0)::INTEGER as axo_pagado
    FROM ta_13_datosrcm d
    LEFT JOIN v_tc_13_cementerios c ON d.cementerio = c.cementerio
    WHERE UPPER(d.nombre) LIKE '%' || UPPER(p_nombre) || '%'
    ORDER BY d.nombre
    LIMIT p_limit;
END;
$function$;

COMMENT ON FUNCTION public.sp_cem_consultar_folios_por_nombre IS 'Busca folios de cementerio por nombre del titular - REQUIERE: ta_13_datosrcm';

-- =====================================================
-- SP 3: sp_cem_consultar_folios_por_ubicacion
-- Estado: Placeholder
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_cem_consultar_folios_por_ubicacion(
    p_cementerio character varying DEFAULT NULL::character varying,
    p_clase integer DEFAULT NULL::integer,
    p_seccion integer DEFAULT NULL::integer
)
RETURNS TABLE(
    success boolean,
    message character varying,
    data jsonb
)
LANGUAGE plpgsql
AS $function$
BEGIN
    -- SP generado automaticamente
    -- TODO: Implementar logica especifica

    -- Consulta generica
    RETURN QUERY
    SELECT
        TRUE::BOOLEAN as success,
        'Consulta ejecutada'::VARCHAR as message,
        '{}'::JSONB as data;
END;
$function$;

COMMENT ON FUNCTION public.sp_cem_consultar_folios_por_ubicacion IS 'Consulta folios por ubicacion (placeholder)';

-- =====================================================
-- SP 4: sp_cem_consultar_pagos_folio
-- Estado: Requiere ta_12_passwords (no crítico)
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_cem_consultar_pagos_folio(
    p_control_rcm integer
)
RETURNS TABLE(
    tipo_pago character varying,
    fecha date,
    recibo character varying,
    importe numeric,
    descuento numeric,
    bonificacion numeric,
    recargo numeric,
    total numeric,
    usuario integer,
    nombre_usuario character varying,
    axo_desde integer,
    axo_hasta integer
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        'MANTENIMIENTO'::VARCHAR as tipo_pago,
        p.fecing::DATE as fecha,
        COALESCE(p.recing::VARCHAR, '')::VARCHAR as recibo,
        COALESCE(p.importe_anual, 0)::DECIMAL as importe,
        0::DECIMAL as descuento,
        0::DECIMAL as bonificacion,
        COALESCE(p.importe_recargos, 0)::DECIMAL as recargo,
        (COALESCE(p.importe_anual, 0) + COALESCE(p.importe_recargos, 0))::DECIMAL as total,
        p.usuario::INTEGER,
        COALESCE(u.nombre, 'SYSTEM')::VARCHAR as nombre_usuario,
        p.axo_pago_desde::INTEGER as axo_desde,
        p.axo_pago_hasta::INTEGER as axo_hasta
    FROM v_ta_13_pagosrcm p
    LEFT JOIN ta_12_passwords u ON p.usuario = u.id_usuario
    WHERE p.control_rcm = p_control_rcm
    ORDER BY p.fecing DESC;
END;
$function$;

COMMENT ON FUNCTION public.sp_cem_consultar_pagos_folio IS 'Consulta detallada de pagos para un folio - REQUIERE: ta_12_passwords (opcional)';

-- =====================================================
-- SP 5: sp_cem_consultar_pagos_por_fecha
-- Estado: Requiere ta_13_datosrcm y ta_12_passwords
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_cem_consultar_pagos_por_fecha(
    p_fecha_desde date,
    p_fecha_hasta date DEFAULT NULL::date,
    p_cementerio character varying DEFAULT NULL::character varying,
    p_limit integer DEFAULT 100
)
RETURNS TABLE(
    recibo integer,
    fecha date,
    control_rcm integer,
    nombre character varying,
    cementerio character varying,
    axo_desde integer,
    axo_hasta integer,
    total numeric,
    usuario character varying
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_fecha_hasta DATE;
BEGIN
    v_fecha_hasta := COALESCE(p_fecha_hasta, CURRENT_DATE);

    RETURN QUERY
    SELECT
        p.recing::INTEGER as recibo,
        p.fecing::DATE as fecha,
        p.control_rcm::INTEGER,
        TRIM(d.nombre)::VARCHAR as nombre,
        d.cementerio::VARCHAR,
        p.axo_pago_desde::INTEGER as axo_desde,
        p.axo_pago_hasta::INTEGER as axo_hasta,
        (COALESCE(p.importe_anual, 0) + COALESCE(p.importe_recargos, 0))::DECIMAL as total,
        COALESCE(u.nombre, 'SYSTEM')::VARCHAR as usuario
    FROM v_ta_13_pagosrcm p
    INNER JOIN ta_13_datosrcm d ON p.control_rcm = d.control_rcm
    LEFT JOIN ta_12_passwords u ON p.usuario = u.id_usuario
    WHERE p.fecing BETWEEN p_fecha_desde AND v_fecha_hasta
    AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
    ORDER BY p.fecing DESC, p.recing DESC
    LIMIT p_limit;
END;
$function$;

COMMENT ON FUNCTION public.sp_cem_consultar_pagos_por_fecha IS 'Consulta pagos en rango de fechas - REQUIERE: ta_13_datosrcm, ta_12_passwords (opcional)';

-- =====================================================
-- SP 6: sp_cem_obtener_pagos_folio
-- Estado: FUNCIONAL
-- =====================================================
CREATE OR REPLACE FUNCTION public.sp_cem_obtener_pagos_folio(
    p_control_rcm integer,
    p_limit integer DEFAULT 50
)
RETURNS TABLE(
    recibo integer,
    fecha date,
    anios character varying,
    importe numeric,
    recargos numeric,
    total numeric
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT
        p.recing::INTEGER as recibo,
        p.fecing::DATE as fecha,
        (p.axo_pago_desde::VARCHAR || '-' || p.axo_pago_hasta::VARCHAR)::VARCHAR as anios,
        COALESCE(p.importe_anual, 0)::DECIMAL as importe,
        COALESCE(p.importe_recargos, 0)::DECIMAL as recargos,
        (COALESCE(p.importe_anual, 0) + COALESCE(p.importe_recargos, 0))::DECIMAL as total
    FROM v_ta_13_pagosrcm p
    WHERE p.control_rcm = p_control_rcm
    ORDER BY p.fecing DESC
    LIMIT p_limit;
END;
$function$;

COMMENT ON FUNCTION public.sp_cem_obtener_pagos_folio IS 'Obtiene resumen de pagos para un folio - FUNCIONAL';

-- =====================================================
-- VERIFICACION POST-DEPLOYMENT
-- =====================================================
-- Verificar vistas creadas
-- SELECT viewname FROM pg_views WHERE schemaname = 'public' AND viewname IN ('v_ta_13_pagosrcm', 'v_tc_13_cementerios');

-- Verificar SPs creados
-- SELECT proname FROM pg_proc WHERE pronamespace = 'public'::regnamespace AND proname LIKE 'sp_cem_%';

-- Probar SP funcional
-- SELECT * FROM public.sp_cem_obtener_pagos_folio(1, 5);

-- =====================================================
-- FIN DEL DEPLOYMENT
-- =====================================================
