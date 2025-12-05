-- ================================================================
-- SP: recaudadora_listado_multiple
-- Módulo: multas_reglamentos
-- Descripción: Listado múltiple de multas con paginación usando tabla real comun.multas
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-03
-- Tabla utilizada: comun.multas (415,017 registros)
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_listado_multiple(VARCHAR);
DROP FUNCTION IF EXISTS db_ingresos.recaudadora_listado_multiple(VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_listado_multiple(
    p_filtro VARCHAR,
    p_limit INTEGER DEFAULT 15,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id_multa INTEGER,
    folio VARCHAR,
    acta VARCHAR,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    num_licencia INTEGER,
    giro VARCHAR,
    multa NUMERIC(10,2),
    gastos NUMERIC(10,2),
    total NUMERIC(10,2),
    tipo VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    -- Convertir filtro a mayúsculas para búsqueda case-insensitive
    v_filtro := UPPER(COALESCE(p_filtro, ''));

    -- Consultar tabla real de multas con paginación
    RETURN QUERY
    SELECT
        m.id_multa,
        ('MULTA-' || COALESCE(m.axo_acta::TEXT, '0000') || '-' || LPAD(COALESCE(m.num_acta, 0)::TEXT, 6, '0'))::VARCHAR AS folio,
        (COALESCE(m.axo_acta::TEXT, 'N/A') || '/' || COALESCE(m.num_acta::TEXT, 'N/A'))::VARCHAR AS acta,
        COALESCE(TRIM(m.contribuyente), 'NO ESPECIFICADO')::VARCHAR AS contribuyente,
        COALESCE(TRIM(m.domicilio), 'NO ESPECIFICADO')::VARCHAR AS domicilio,
        m.num_licencia,
        COALESCE(TRIM(m.giro), 'NO ESPECIFICADO')::VARCHAR AS giro,
        COALESCE(m.multa, 0)::NUMERIC(10,2) AS multa,
        COALESCE(m.gastos, 0)::NUMERIC(10,2) AS gastos,
        COALESCE(m.total, 0)::NUMERIC(10,2) AS total,
        (CASE
            WHEN m.tipo = 'N' THEN 'Normal'
            WHEN m.tipo = 'R' THEN 'Reincidente'
            WHEN m.tipo = 'S' THEN 'Especial'
            ELSE 'No Especificado'
        END)::VARCHAR AS tipo
    FROM comun.multas m
    WHERE
        m.total > 0
        AND m.contribuyente IS NOT NULL
        AND m.axo_acta > 0
        AND m.axo_acta < 2100
        AND (
            v_filtro = ''
            OR UPPER(COALESCE(m.contribuyente, '')) LIKE '%' || v_filtro || '%'
            OR UPPER(COALESCE(m.domicilio, '')) LIKE '%' || v_filtro || '%'
            OR UPPER(COALESCE(m.giro, '')) LIKE '%' || v_filtro || '%'
            OR m.num_acta::TEXT LIKE '%' || v_filtro || '%'
            OR m.num_licencia::TEXT LIKE '%' || v_filtro || '%'
            OR m.axo_acta::TEXT LIKE '%' || v_filtro || '%'
        )
    ORDER BY
        m.axo_acta DESC,
        m.num_acta DESC,
        m.id_multa DESC
    LIMIT p_limit
    OFFSET p_offset;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_listado_multiple(VARCHAR, INTEGER, INTEGER) IS
'Listado múltiple de multas con paginación usando la tabla real comun.multas.
Parámetros:
  - p_filtro: Término de búsqueda (contribuyente, domicilio, giro, acta, licencia, año)
  - p_limit: Número de registros por página (default: 15)
  - p_offset: Número de registros a saltar (default: 0)
Retorna: Multas reales del sistema con folio, contribuyente, importes y tipo.
Tabla utilizada: comun.multas (415,017 registros).';

-- ================================================================
-- SP: recaudadora_listado_multiple_count
-- Descripción: Cuenta el total de registros para paginación
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_listado_multiple_count(VARCHAR);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_listado_multiple_count(
    p_filtro VARCHAR
)
RETURNS TABLE (
    total BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    -- Convertir filtro a mayúsculas para búsqueda case-insensitive
    v_filtro := UPPER(COALESCE(p_filtro, ''));

    -- Contar registros que coinciden con el filtro
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT
    FROM comun.multas m
    WHERE
        m.total > 0
        AND m.contribuyente IS NOT NULL
        AND m.axo_acta > 0
        AND m.axo_acta < 2100
        AND (
            v_filtro = ''
            OR UPPER(COALESCE(m.contribuyente, '')) LIKE '%' || v_filtro || '%'
            OR UPPER(COALESCE(m.domicilio, '')) LIKE '%' || v_filtro || '%'
            OR UPPER(COALESCE(m.giro, '')) LIKE '%' || v_filtro || '%'
            OR m.num_acta::TEXT LIKE '%' || v_filtro || '%'
            OR m.num_licencia::TEXT LIKE '%' || v_filtro || '%'
            OR m.axo_acta::TEXT LIKE '%' || v_filtro || '%'
        );

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_listado_multiple_count(VARCHAR) IS
'Cuenta el total de registros de multas que coinciden con el filtro.
Parámetros:
  - p_filtro: Término de búsqueda
Retorna: Total de registros encontrados.';
