CREATE OR REPLACE FUNCTION publico.recaudadora_regsecymas(
    p_busqueda VARCHAR
)
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje VARCHAR,
    nombre VARCHAR,
    ini_rfc VARCHAR,
    hom_rfc VARCHAR,
    id_rec VARCHAR,
    categoria VARCHAR,
    vigencia VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id_ejecutor,
        e.cve_eje::VARCHAR,
        e.nombre::VARCHAR,
        e.ini_rfc::VARCHAR,
        e.hom_rfc::VARCHAR,
        e.id_rec::VARCHAR,
        e.categoria::VARCHAR,
        e.vigencia::VARCHAR
    FROM publico.ejecutores_administrativos e
    WHERE
        CASE
            WHEN p_busqueda = '' OR p_busqueda IS NULL THEN TRUE
            ELSE (
                e.nombre ILIKE '%' || p_busqueda || '%'
                OR e.cve_eje ILIKE '%' || p_busqueda || '%'
                OR e.ini_rfc ILIKE '%' || p_busqueda || '%'
                OR e.id_rec ILIKE '%' || p_busqueda || '%'
            )
        END
    ORDER BY e.cve_eje, e.nombre;
END; $$;
