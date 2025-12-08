-- SP para obtener todas las tablas disponibles
CREATE OR REPLACE FUNCTION sp_otras_oblig_get_tablas_all()
RETURNS TABLE (
    cve_tab integer,
    nombre varchar
) AS $func$
BEGIN
    RETURN QUERY
    SELECT
        TRIM(t.cve_tab)::integer AS cve_tab,
        t.nombre::varchar
    FROM t34_tablas t
    WHERE t.cve_tab ~ '^[0-9]+$'
    ORDER BY TRIM(t.cve_tab)::integer;
END;
$func$ LANGUAGE plpgsql;
