-- Stored Procedure: sp_cem_reporte_cuentas_cobrar
-- Migrado de padron_licencias.comun a cementerio.public
-- Fecha: 2025-11-26

CREATE OR REPLACE FUNCTION public.sp_cem_reporte_cuentas_cobrar(
    p_cementerio character varying DEFAULT NULL::character varying,
    p_anio integer DEFAULT NULL::integer
)
RETURNS TABLE(
    control_rcm character varying,
    cementerio character varying,
    nombre character varying,
    domicilio character varying,
    axo_pagado integer,
    anios_adeudo integer
)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_anio_ref INTEGER;
BEGIN
    v_anio_ref := COALESCE(p_anio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'datosrcm' AND table_schema = 'public') THEN
        RETURN QUERY
        SELECT
            d.control_rcm::VARCHAR,
            d.cementerio::VARCHAR,
            d.nombre::VARCHAR,
            COALESCE(d.domicilio, '')::VARCHAR,
            COALESCE(d.axo_pagado, v_anio_ref)::INTEGER,
            (v_anio_ref - COALESCE(d.axo_pagado, v_anio_ref))::INTEGER as anios_adeudo
        FROM datosrcm d
        WHERE COALESCE(d.axo_pagado, v_anio_ref) < v_anio_ref
          AND (p_cementerio IS NULL OR d.cementerio = p_cementerio)
        ORDER BY anios_adeudo DESC, d.cementerio, d.control_rcm;
    END IF;
END;
$function$;
