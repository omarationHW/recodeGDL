-- ========================================================================
-- SP: sp_catalogo_secciones
-- Devuelve el catálogo de secciones disponibles
-- ========================================================================
CREATE OR REPLACE FUNCTION sp_catalogo_secciones()
RETURNS TABLE (
    clave VARCHAR,
    descripcion VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        l.seccion::VARCHAR AS clave,
        CASE l.seccion
            WHEN '01' THEN 'SECCION 01'
            WHEN '02' THEN 'SECCION 02'
            WHEN 'EA' THEN 'ENERGIA ALUMBRADO'
            WHEN 'PS' THEN 'PLAZAS Y SECTORES'
            WHEN 'SS' THEN 'SOBRE SUELO'
            WHEN 'T1' THEN 'TIPO 1'
            WHEN 'T2' THEN 'TIPO 2'
            ELSE l.seccion::VARCHAR
        END AS descripcion
    FROM mercados.public.ta_11_cuo_locales l
    WHERE l.seccion IS NOT NULL
    ORDER BY clave;
END;
$$;
