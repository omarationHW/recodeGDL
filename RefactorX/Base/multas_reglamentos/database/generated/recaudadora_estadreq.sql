-- ================================================================
-- SP: recaudadora_estadreq
-- Módulo: multas_reglamentos
-- Descripción: Estadísticas y resumen de requerimientos por ejecutor
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-02
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_estadreq(
    p_q VARCHAR DEFAULT ''
)
RETURNS TABLE (
    ejecutor TEXT,
    id_ejecutor INTEGER,
    cve_ejecutor TEXT,
    categoria TEXT,
    oficio TEXT,
    total_asignaciones INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Retornar estadísticas de ejecutores/empresas
    -- Filtrado por nombre, categoría, ID o clave
    RETURN QUERY
    SELECT
        COALESCE(TRIM(e.nombre), 'Sin nombre')::TEXT AS ejecutor,
        e.id_ejecutor::INTEGER AS id_ejecutor,
        COALESCE(TRIM(CAST(e.cve_eje AS TEXT)), '')::TEXT AS cve_ejecutor,
        COALESCE(TRIM(e.categoria), '')::TEXT AS categoria,
        COALESCE(TRIM(e.oficio), '')::TEXT AS oficio,
        0::INTEGER AS total_asignaciones -- Placeholder: ajustar cuando existan tablas de requerimientos
    FROM comun.ta_15_ejecutores e
    WHERE
        (
            p_q IS NULL
            OR p_q = ''
            OR LOWER(e.nombre) LIKE LOWER('%' || p_q || '%')
            OR LOWER(e.categoria) LIKE LOWER('%' || p_q || '%')
            OR CAST(e.id_ejecutor AS TEXT) LIKE '%' || p_q || '%'
            OR CAST(e.cve_eje AS TEXT) LIKE '%' || p_q || '%'
        )
    ORDER BY e.nombre
    LIMIT 100;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en estadreq: %', SQLERRM;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_estadreq(VARCHAR) IS 'Estadísticas de requerimientos por ejecutor';
