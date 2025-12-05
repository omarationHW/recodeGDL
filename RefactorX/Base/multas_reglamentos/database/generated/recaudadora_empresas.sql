-- ================================================================
-- SP: recaudadora_empresas
-- Módulo: multas_reglamentos
-- Descripción: Consulta catálogo de empresas/ejecutores con paginación
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-01
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_empresas(
    p_q VARCHAR DEFAULT '',
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    empresa TEXT,
    nombre TEXT,
    rfc TEXT,
    contacto TEXT,
    estatus TEXT,
    id_ejecutor INTEGER,
    cve_ejecutor TEXT,
    observacion TEXT,
    oficio TEXT,
    total_count BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Obtener el total de registros que coinciden con el filtro
    SELECT COUNT(*)
    INTO v_total
    FROM comun.ta_15_ejecutores e
    WHERE
        (
            p_q IS NULL
            OR p_q = ''
            OR LOWER(e.nombre) LIKE LOWER('%' || p_q || '%')
            OR LOWER(e.categoria) LIKE LOWER('%' || p_q || '%')
            OR CAST(e.id_ejecutor AS TEXT) LIKE '%' || p_q || '%'
            OR CAST(e.cve_eje AS TEXT) LIKE '%' || p_q || '%'
        );

    -- Retornar los registros paginados con el total en cada fila
    RETURN QUERY
    SELECT
        COALESCE(TRIM(e.nombre), '')::TEXT AS empresa,
        COALESCE(TRIM(e.nombre), '')::TEXT AS nombre,
        COALESCE(TRIM(CAST(e.cve_eje AS TEXT)), '')::TEXT AS rfc,
        COALESCE(TRIM(e.categoria), '')::TEXT AS contacto,
        CASE
            WHEN e.id_ejecutor IS NOT NULL THEN 'Activo'
            ELSE 'Inactivo'
        END::TEXT AS estatus,
        COALESCE(e.id_ejecutor, 0)::INTEGER AS id_ejecutor,
        COALESCE(TRIM(CAST(e.cve_eje AS TEXT)), '')::TEXT AS cve_ejecutor,
        COALESCE(TRIM(e.observacion), '')::TEXT AS observacion,
        COALESCE(TRIM(e.oficio), '')::TEXT AS oficio,
        v_total AS total_count
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
    LIMIT p_limit
    OFFSET p_offset;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_empresas(VARCHAR, INTEGER, INTEGER) IS 'Consulta catálogo de empresas/ejecutores con paginación desde comun.ta_15_ejecutores';
