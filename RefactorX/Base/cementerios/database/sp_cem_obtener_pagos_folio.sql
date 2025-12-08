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
