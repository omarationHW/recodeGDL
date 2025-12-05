-- ================================================================
-- SP: recaudadora_multasfrm
-- Módulo: multas_reglamentos
-- Descripción: Consulta general de multas con búsqueda por filtro
-- Tabla principal: comun.multas (415,017 registros)
-- ================================================================
-- Parámetros:
--   p_filtro (VARCHAR): Filtro de búsqueda (busca en contribuyente, folio, domicilio, giro)
-- ================================================================
-- Retorna:
--   id_multa: ID de la multa
--   folio: Número de acta
--   anio: Año del acta
--   fecha_acta: Fecha del acta
--   contribuyente: Nombre del contribuyente
--   domicilio: Domicilio
--   giro: Giro del negocio
--   licencia: Número de licencia
--   calificacion: Monto de la calificación
--   multa: Monto de la multa
--   gastos: Gastos administrativos
--   total: Total a pagar
--   estatus: Estado de la multa
-- ================================================================

CREATE OR REPLACE FUNCTION comun.recaudadora_multasfrm(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    id_multa INTEGER,
    folio INTEGER,
    anio INTEGER,
    fecha_acta DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    giro VARCHAR,
    licencia INTEGER,
    calificacion NUMERIC,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    estatus VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.id_multa,
        m.num_acta AS folio,
        m.axo_acta::INTEGER AS anio,
        m.fecha_acta,
        COALESCE(m.contribuyente, 'N/A') AS contribuyente,
        COALESCE(m.domicilio, 'N/A') AS domicilio,
        COALESCE(m.giro, 'N/A') AS giro,
        COALESCE(m.num_licencia, 0) AS licencia,
        COALESCE(m.calificacion, 0.00) AS calificacion,
        COALESCE(m.multa, 0.00) AS multa,
        COALESCE(m.gastos, 0.00) AS gastos,
        COALESCE(m.total, 0.00) AS total,
        CAST(CASE
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'CANCELADA'
            WHEN m.cvepago IS NOT NULL THEN 'PAGADA'
            ELSE 'PENDIENTE'
        END AS VARCHAR) AS estatus
    FROM comun.multas m
    WHERE
        (p_filtro = '' OR
         m.contribuyente ILIKE '%' || p_filtro || '%' OR
         CAST(m.num_acta AS VARCHAR) LIKE '%' || p_filtro || '%' OR
         m.domicilio ILIKE '%' || p_filtro || '%' OR
         m.giro ILIKE '%' || p_filtro || '%' OR
         CAST(m.num_licencia AS VARCHAR) LIKE '%' || p_filtro || '%')
    ORDER BY m.id_multa DESC
    LIMIT 100;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.recaudadora_multasfrm IS 'Consulta general de multas con búsqueda por filtro en múltiples campos';
