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
