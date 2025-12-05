-- ================================================================
-- SP: recaudadora_ejecutores
-- Módulo: multas_reglamentos
-- Descripción: Consulta catálogo de ejecutores
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-01
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_ejecutores(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_ejecutor TEXT,
    cve_ejecutor TEXT,
    nombre TEXT,
    categoria TEXT,
    observacion TEXT,
    oficio TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Buscar ejecutores en el catálogo
    -- Si se proporciona filtro, buscar por nombre o categoría
    -- Si no se proporciona, mostrar todos (limitado a 100 registros)

    RETURN QUERY
    SELECT
        CAST(e.id_ejecutor AS TEXT) AS id_ejecutor,
        CAST(e.cve_eje AS TEXT) AS cve_ejecutor,
        CAST(TRIM(e.nombre) AS TEXT) AS nombre,
        CAST(TRIM(e.categoria) AS TEXT) AS categoria,
        CAST(TRIM(e.observacion) AS TEXT) AS observacion,
        CAST(TRIM(e.oficio) AS TEXT) AS oficio
    FROM comun.ta_15_ejecutores e
    WHERE
        (
            p_filtro IS NULL
            OR p_filtro = ''
            OR LOWER(e.nombre) LIKE LOWER('%' || p_filtro || '%')
            OR LOWER(e.categoria) LIKE LOWER('%' || p_filtro || '%')
            OR CAST(e.id_ejecutor AS TEXT) = p_filtro
            OR CAST(e.cve_eje AS TEXT) = p_filtro
        )
    ORDER BY e.nombre
    LIMIT 100;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_ejecutores(VARCHAR) IS 'Consulta catálogo de ejecutores desde comun.ta_15_ejecutores';
