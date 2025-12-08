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
