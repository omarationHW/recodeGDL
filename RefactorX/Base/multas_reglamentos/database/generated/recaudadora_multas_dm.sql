-- ================================================================
-- SP: recaudadora_multas_dm
-- Módulo: multas_reglamentos
-- Descripción: Consulta de multas con paginación
-- Tabla principal: comun.multas (415,017 registros)
-- ================================================================
-- Parámetros:
--   p_clave_cuenta (VARCHAR): Clave de cuenta para filtrar (opcional)
--   p_ejercicio (INTEGER): Año del ejercicio (opcional)
--   p_offset (INTEGER): Offset para paginación (default: 0)
--   p_limit (INTEGER): Límite de registros por página (default: 10)
-- ================================================================
-- Retorna:
--   clave_cuenta: Clave de pago del contribuyente
--   folio: Número de acta de la multa
--   ejercicio: Año del acta
--   importe: Total de la multa
--   estatus: Estado de la multa (PENDIENTE, PAGADA, CANCELADA)
--   total_registros: Total de registros que cumplen los criterios
-- ================================================================

CREATE OR REPLACE FUNCTION comun.recaudadora_multas_dm(
    p_clave_cuenta VARCHAR DEFAULT '',
    p_ejercicio INTEGER DEFAULT 0,
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    clave_cuenta VARCHAR,
    folio INTEGER,
    ejercicio INTEGER,
    importe NUMERIC,
    estatus VARCHAR,
    total_registros BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Calcular el total de registros que cumplen los criterios
    SELECT COUNT(*) INTO v_total
    FROM comun.multas m
    WHERE
        (p_clave_cuenta = '' OR CAST(m.cvepago AS VARCHAR) LIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR m.axo_acta = p_ejercicio);

    -- Retornar los registros paginados con el total
    RETURN QUERY
    SELECT
        COALESCE(CAST(m.cvepago AS VARCHAR), 'N/A') AS clave_cuenta,
        COALESCE(m.num_acta, 0) AS folio,
        COALESCE(m.axo_acta::INTEGER, 0) AS ejercicio,
        COALESCE(m.total, 0.00) AS importe,
        CAST(CASE
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'CANCELADA'
            WHEN m.cvepago IS NOT NULL THEN 'PAGADA'
            ELSE 'PENDIENTE'
        END AS VARCHAR) AS estatus,
        v_total AS total_registros
    FROM comun.multas m
    WHERE
        (p_clave_cuenta = '' OR CAST(m.cvepago AS VARCHAR) LIKE '%' || p_clave_cuenta || '%')
        AND (p_ejercicio = 0 OR m.axo_acta = p_ejercicio)
    ORDER BY m.axo_acta DESC, m.num_acta DESC
    OFFSET p_offset
    LIMIT p_limit;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.recaudadora_multas_dm IS 'Consulta de multas con paginación, permite filtrar por cuenta y ejercicio fiscal';
