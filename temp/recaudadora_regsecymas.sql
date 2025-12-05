-- ================================================================
-- SP: recaudadora_regsecymas
-- Módulo: multas_reglamentos
-- Descripción: Búsqueda de ejecutores administrativos
-- Parámetros:
--   p_busqueda: Texto para buscar en nombre, RFC o categoría
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_regsecymas(TEXT);

CREATE OR REPLACE FUNCTION public.recaudadora_regsecymas(
    p_busqueda TEXT DEFAULT ''
)
RETURNS TABLE (
    id_ejecutor INTEGER,
    cve_eje INTEGER,
    nombre VARCHAR,
    ini_rfc CHAR,
    fec_rfc DATE,
    hom_rfc CHAR,
    id_rec SMALLINT,
    categoria VARCHAR,
    observacion VARCHAR,
    fecinic DATE,
    fecterm DATE,
    vigencia CHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_busqueda TEXT;
BEGIN
    -- Normalizar búsqueda (quitar espacios extras y convertir a mayúsculas)
    v_busqueda := UPPER(TRIM(COALESCE(p_busqueda, '')));

    RETURN QUERY
    SELECT
        e.id_ejecutor,
        e.cve_eje,
        e.nombre,
        e.ini_rfc,
        e.fec_rfc,
        e.hom_rfc,
        e.id_rec,
        e.categoria,
        e.observacion,
        e.fecinic,
        e.fecterm,
        e.vigencia
    FROM comun.ta_15_ejecutores e
    WHERE
        -- Si hay búsqueda, filtrar por nombre, RFC o categoría
        (v_busqueda = '' OR
         UPPER(e.nombre) LIKE '%' || v_busqueda || '%' OR
         UPPER(e.ini_rfc) LIKE '%' || v_busqueda || '%' OR
         UPPER(e.categoria) LIKE '%' || v_busqueda || '%' OR
         CAST(e.cve_eje AS TEXT) LIKE '%' || v_busqueda || '%')
    ORDER BY e.nombre
    LIMIT 100;

END;
$$;

COMMENT ON FUNCTION public.recaudadora_regsecymas(TEXT) IS 'Búsqueda de ejecutores administrativos por nombre, RFC o categoría';
