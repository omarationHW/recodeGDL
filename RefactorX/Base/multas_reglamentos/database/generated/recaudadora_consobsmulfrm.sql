-- ================================================================
-- SP: recaudadora_consobsmulfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta observaciones de multas con búsqueda por texto
-- Autor: Sistema RefactorX
-- Fecha: 2025-11-28
-- ================================================================

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_consobsmulfrm(
    p_filtro VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id_multa INTEGER,
    contribuyente VARCHAR(306),
    domicilio VARCHAR(336),
    num_acta INTEGER,
    axo_acta SMALLINT,
    id_dependencia SMALLINT,
    fecha_acta DATE,
    observacion TEXT,
    comentario VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Si se proporciona un filtro, buscar multas que coincidan
    IF p_filtro IS NOT NULL AND p_filtro != '' THEN
        RETURN QUERY
        SELECT
            m.id_multa,
            m.contribuyente,
            m.domicilio,
            m.num_acta,
            m.axo_acta,
            m.id_dependencia,
            m.fecha_acta,
            m.observacion,
            m.comentario
        FROM comun.multas m
        WHERE
            m.contribuyente ILIKE '%' || p_filtro || '%'
            OR m.observacion ILIKE '%' || p_filtro || '%'
            OR m.comentario ILIKE '%' || p_filtro || '%'
            OR CAST(m.num_acta AS TEXT) LIKE '%' || p_filtro || '%'
            OR CAST(m.axo_acta AS TEXT) LIKE '%' || p_filtro || '%'
        ORDER BY m.id_multa DESC
        LIMIT 100;
    ELSE
        -- Si no se proporciona filtro, listar las últimas 50 multas con observaciones
        RETURN QUERY
        SELECT
            m.id_multa,
            m.contribuyente,
            m.domicilio,
            m.num_acta,
            m.axo_acta,
            m.id_dependencia,
            m.fecha_acta,
            m.observacion,
            m.comentario
        FROM comun.multas m
        WHERE m.observacion IS NOT NULL OR m.comentario IS NOT NULL
        ORDER BY m.id_multa DESC
        LIMIT 50;
    END IF;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_consobsmulfrm(VARCHAR) IS 'Consulta observaciones de multas con búsqueda por contribuyente, observación, comentario o número de acta.';
