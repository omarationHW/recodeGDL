-- Stored Procedure: sp_cem_reporte_titulos
-- Migrado de padron_licencias.comun a cementerio.public
-- Fecha: 2025-11-26

CREATE OR REPLACE FUNCTION public.sp_cem_reporte_titulos(
    p_fecha_desde date,
    p_fecha_hasta date,
    p_cementerio character varying DEFAULT NULL::character varying
)
RETURNS TABLE(
    titulo character varying,
    fecha date,
    control_rcm character varying,
    nombre character varying,
    cementerio character varying,
    clase integer,
    seccion integer,
    linea integer,
    fosa integer,
    importe numeric,
    recaudacion character varying
)
LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'titulos' AND table_schema = 'public') THEN
        RETURN QUERY
        SELECT
            t.titulo::VARCHAR,
            t.fecha::DATE,
            t.control_rcm::VARCHAR,
            t.nombre::VARCHAR,
            t.cementerio::VARCHAR,
            t.clase::INTEGER,
            t.seccion::INTEGER,
            t.linea::INTEGER,
            t.fosa::INTEGER,
            COALESCE(t.importe, 0)::DECIMAL,
            COALESCE(t.recaudacion, '')::VARCHAR
        FROM titulos t
        WHERE t.fecha BETWEEN p_fecha_desde AND p_fecha_hasta
          AND (p_cementerio IS NULL OR t.cementerio = p_cementerio)
        ORDER BY t.fecha DESC, t.titulo;
    END IF;
END;
$function$;
