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
