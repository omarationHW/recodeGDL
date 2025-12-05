-- ================================================================
-- SP: recaudadora_newsfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta de novedades de multas (multas recientes) con paginación
-- Tabla principal: comun.multas (415,017 registros)
-- ================================================================
-- Parámetros:
--   p_filtro (VARCHAR): Filtro de búsqueda (busca en contribuyente, folio, año)
--   p_offset (INTEGER): Offset para paginación (default: 0)
--   p_limit (INTEGER): Límite de registros por página (default: 10)
-- ================================================================
-- Retorna:
--   id_multa: ID de la multa
--   folio: Número de acta
--   anio: Año del acta
--   fecha_acta: Fecha del acta
--   fecha_recepcion: Fecha de recepción
--   contribuyente: Nombre del contribuyente
--   domicilio: Domicilio
--   giro: Giro del negocio
--   total: Total de la multa
--   estatus: Estado de la multa
--   total_registros: Total de registros que cumplen los criterios
-- ================================================================

CREATE OR REPLACE FUNCTION comun.recaudadora_newsfrm(
    p_filtro VARCHAR DEFAULT '',
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id_multa INTEGER,
    folio INTEGER,
    anio INTEGER,
    fecha_acta DATE,
    fecha_recepcion DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    giro VARCHAR,
    total NUMERIC,
    estatus VARCHAR,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Calcular el total de registros que cumplen los criterios
    -- Filtra por años válidos (1990-2030) para evitar datos incorrectos
    SELECT COUNT(*) INTO v_total
    FROM comun.multas m
    WHERE
        m.axo_acta BETWEEN 1990 AND 2030
        AND (p_filtro = '' OR
             m.contribuyente ILIKE '%' || p_filtro || '%' OR
             CAST(m.num_acta AS VARCHAR) LIKE '%' || p_filtro || '%' OR
             CAST(m.axo_acta AS VARCHAR) LIKE '%' || p_filtro || '%' OR
             m.domicilio ILIKE '%' || p_filtro || '%');

    -- Retornar los registros paginados ordenados por fecha más reciente
    RETURN QUERY
    SELECT
        m.id_multa,
        m.num_acta AS folio,
        m.axo_acta::INTEGER AS anio,
        m.fecha_acta,
        m.fecha_recepcion,
        COALESCE(m.contribuyente, 'N/A') AS contribuyente,
        COALESCE(m.domicilio, 'N/A') AS domicilio,
        COALESCE(m.giro, 'N/A') AS giro,
        COALESCE(m.total, 0.00) AS total,
        CAST(CASE
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'CANCELADA'
            WHEN m.cvepago IS NOT NULL THEN 'PAGADA'
            ELSE 'PENDIENTE'
        END AS VARCHAR) AS estatus,
        v_total AS total_registros
    FROM comun.multas m
    WHERE
        m.axo_acta BETWEEN 1990 AND 2030
        AND (p_filtro = '' OR
             m.contribuyente ILIKE '%' || p_filtro || '%' OR
             CAST(m.num_acta AS VARCHAR) LIKE '%' || p_filtro || '%' OR
             CAST(m.axo_acta AS VARCHAR) LIKE '%' || p_filtro || '%' OR
             m.domicilio ILIKE '%' || p_filtro || '%')
    ORDER BY m.axo_acta DESC, m.fecha_acta DESC NULLS LAST, m.id_multa DESC
    OFFSET p_offset
    LIMIT p_limit;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.recaudadora_newsfrm IS 'Consulta de novedades de multas (multas recientes) con paginación y filtro de búsqueda';
