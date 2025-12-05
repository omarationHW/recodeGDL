-- ================================================================
-- SP: recaudadora_multas400frm
-- Módulo: multas_reglamentos
-- Descripción: Listado de multas con búsqueda por ID, acta o contribuyente
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-03
-- Tabla: comun.multas (415,017 registros)
-- ================================================================

DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_multas400frm(VARCHAR);

CREATE OR REPLACE FUNCTION multas_reglamentos.recaudadora_multas400frm(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_multa INTEGER,
    num_acta INTEGER,
    axo_acta SMALLINT,
    fecha_acta DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    id_dependencia SMALLINT,
    expediente VARCHAR,
    multa NUMERIC(12,2),
    gastos NUMERIC(12,2),
    total NUMERIC(12,2),
    cvepago INTEGER,
    fecha_recepcion DATE,
    observacion TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_filtro VARCHAR;
BEGIN
    -- Convertir filtro a mayúsculas
    v_filtro := UPPER(COALESCE(p_filtro, ''));

    -- Consultar multas
    RETURN QUERY
    SELECT
        m.id_multa::INTEGER,
        COALESCE(m.num_acta, 0)::INTEGER AS num_acta,
        COALESCE(m.axo_acta, 0)::SMALLINT AS axo_acta,
        m.fecha_acta::DATE,
        COALESCE(TRIM(m.contribuyente), 'NO ESPECIFICADO')::VARCHAR AS contribuyente,
        COALESCE(TRIM(m.domicilio), 'N/A')::VARCHAR AS domicilio,
        COALESCE(m.id_dependencia, 0)::SMALLINT AS id_dependencia,
        COALESCE(TRIM(m.expediente), 'N/A')::VARCHAR AS expediente,
        COALESCE(m.multa, 0)::NUMERIC(12,2) AS multa,
        COALESCE(m.gastos, 0)::NUMERIC(12,2) AS gastos,
        COALESCE(m.total, 0)::NUMERIC(12,2) AS total,
        m.cvepago::INTEGER,
        m.fecha_recepcion::DATE,
        COALESCE(m.observacion, 'N/A')::TEXT AS observacion
    FROM comun.multas m
    WHERE
        m.total > 0
        AND (
            v_filtro = ''
            OR m.id_multa::TEXT LIKE '%' || v_filtro || '%'
            OR COALESCE(m.num_acta::TEXT, '') LIKE '%' || v_filtro || '%'
            OR UPPER(COALESCE(m.contribuyente, '')) LIKE '%' || v_filtro || '%'
            OR UPPER(COALESCE(m.expediente, '')) LIKE '%' || v_filtro || '%'
        )
    ORDER BY
        m.fecha_acta DESC NULLS LAST,
        m.id_multa DESC
    LIMIT 100;

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION multas_reglamentos.recaudadora_multas400frm(VARCHAR) IS
'Listado de multas con búsqueda múltiple.
Tabla origen: comun.multas (415,017 registros).
Parámetro:
  - p_filtro: Filtro de búsqueda (ID multa, número de acta, contribuyente, expediente) - opcional
Retorna: Máximo 100 multas ordenadas por fecha descendente.
Búsqueda en: ID multa, número de acta, contribuyente, expediente.';
