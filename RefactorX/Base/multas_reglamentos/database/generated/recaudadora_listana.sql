-- ================================================================
-- SP: recaudadora_listana
-- Módulo: multas_reglamentos
-- Descripción: Listado analítico de multas con paginación server-side usando tabla real comun.multas
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-03
-- Tabla utilizada: comun.multas (415,017 registros)
-- ================================================================

DROP FUNCTION IF EXISTS db_ingresos.recaudadora_listana(VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_listana(
    p_filtro VARCHAR,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    total_count BIGINT,
    id_multa INTEGER,
    folio VARCHAR,
    fecha_acta DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    dependencia VARCHAR,
    zona_subzona VARCHAR,
    calificacion NUMERIC(10,2),
    multa NUMERIC(10,2),
    gastos NUMERIC(10,2),
    total NUMERIC(10,2),
    tipo VARCHAR,
    estado VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro VARCHAR;
    v_total_count BIGINT;
BEGIN
    -- Convertir filtro a mayúsculas para búsqueda case-insensitive
    v_filtro := UPPER(COALESCE(p_filtro, ''));

    -- Obtener el conteo total una vez
    SELECT COUNT(*)
    INTO v_total_count
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
            OR m.axo_acta::TEXT LIKE '%' || v_filtro || '%'
        );

    -- Consultar tabla real de multas con información analítica y paginación
    RETURN QUERY
    SELECT
        v_total_count AS total_count,
        m.id_multa,
        ('MULTA-' || COALESCE(m.axo_acta::TEXT, '0000') || '-' || LPAD(COALESCE(m.num_acta, 0)::TEXT, 6, '0'))::VARCHAR AS folio,
        m.fecha_acta,
        COALESCE(TRIM(m.contribuyente), 'NO ESPECIFICADO')::VARCHAR AS contribuyente,
        COALESCE(TRIM(m.domicilio), 'NO ESPECIFICADO')::VARCHAR AS domicilio,
        (CASE
            WHEN m.id_dependencia = 1 THEN 'Protección Civil'
            WHEN m.id_dependencia = 2 THEN 'Padrón y Licencias'
            WHEN m.id_dependencia = 3 THEN 'Inspección y Vigilancia'
            WHEN m.id_dependencia = 4 THEN 'Reglamentos'
            WHEN m.id_dependencia = 5 THEN 'Mercados'
            ELSE 'Dependencia ' || COALESCE(m.id_dependencia::TEXT, 'N/A')
        END)::VARCHAR AS dependencia,
        (COALESCE('Z' || m.zona::TEXT, 'N/A') || ' / ' || COALESCE('SZ' || m.subzona::TEXT, 'N/A'))::VARCHAR AS zona_subzona,
        COALESCE(m.calificacion, 0)::NUMERIC(10,2) AS calificacion,
        COALESCE(m.multa, 0)::NUMERIC(10,2) AS multa,
        COALESCE(m.gastos, 0)::NUMERIC(10,2) AS gastos,
        COALESCE(m.total, 0)::NUMERIC(10,2) AS total,
        (CASE
            WHEN m.tipo = 'N' THEN 'Normal'
            WHEN m.tipo = 'R' THEN 'Reincidente'
            WHEN m.tipo = 'S' THEN 'Especial'
            ELSE 'No Especificado'
        END)::VARCHAR AS tipo,
        (CASE
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'Cancelada'
            WHEN m.cvepago IS NOT NULL THEN 'Pagada'
            ELSE 'Pendiente'
        END)::VARCHAR AS estado
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
COMMENT ON FUNCTION db_ingresos.recaudadora_listana(VARCHAR, INTEGER, INTEGER) IS
'Listado analítico de multas con paginación server-side usando la tabla real comun.multas.
Incluye información analítica detallada: dependencia, zona/subzona, estado de pago, calificación.
Parámetros:
  - p_filtro: Término de búsqueda (contribuyente, domicilio, giro, acta, año)
  - p_offset: Número de registros a saltar (default: 0)
  - p_limit: Número de registros por página (default: 10)
Retorna: Multas reales con análisis detallado y total_count para paginación server-side.
Tabla utilizada: comun.multas (415,017 registros).';
