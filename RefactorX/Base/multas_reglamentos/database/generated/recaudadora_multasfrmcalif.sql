-- ================================================================
-- SP: recaudadora_multasfrmcalif
-- Módulo: multas_reglamentos
-- Descripción: Consulta de calificación de multas por cuenta con paginación
-- Tabla principal: comun.multas (415,017 registros)
-- ================================================================
-- Parámetros:
--   p_clave_cuenta (VARCHAR): Clave de cuenta/pago para filtrar
--   p_offset (INTEGER): Offset para paginación (default: 0)
--   p_limit (INTEGER): Límite de registros por página (default: 10)
-- ================================================================
-- Retorna:
--   id_multa: ID de la multa
--   folio: Número de acta
--   anio: Año del acta
--   fecha_acta: Fecha del acta
--   contribuyente: Nombre del contribuyente
--   domicilio: Domicilio
--   ley: ID de ley
--   infraccion: ID de infracción
--   calificacion: Monto de calificación
--   multa: Monto de la multa
--   gastos: Gastos administrativos
--   total: Total a pagar
--   observacion: Observaciones
--   estatus: Estado de la multa
--   total_registros: Total de registros que cumplen los criterios
-- ================================================================

CREATE OR REPLACE FUNCTION comun.recaudadora_multasfrmcalif(
    p_clave_cuenta VARCHAR DEFAULT '',
    p_offset INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id_multa INTEGER,
    folio INTEGER,
    anio INTEGER,
    fecha_acta DATE,
    contribuyente VARCHAR,
    domicilio VARCHAR,
    ley SMALLINT,
    infraccion SMALLINT,
    calificacion NUMERIC,
    multa NUMERIC,
    gastos NUMERIC,
    total NUMERIC,
    observacion TEXT,
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
        (p_clave_cuenta = '' OR CAST(m.cvepago AS VARCHAR) = p_clave_cuenta);

    -- Retornar los registros paginados con el total
    RETURN QUERY
    SELECT
        m.id_multa,
        m.num_acta AS folio,
        m.axo_acta::INTEGER AS anio,
        m.fecha_acta,
        COALESCE(m.contribuyente, 'N/A') AS contribuyente,
        COALESCE(m.domicilio, 'N/A') AS domicilio,
        m.id_ley AS ley,
        m.id_infraccion AS infraccion,
        COALESCE(m.calificacion, 0.00) AS calificacion,
        COALESCE(m.multa, 0.00) AS multa,
        COALESCE(m.gastos, 0.00) AS gastos,
        COALESCE(m.total, 0.00) AS total,
        m.observacion,
        CAST(CASE
            WHEN m.fecha_cancelacion IS NOT NULL THEN 'CANCELADA'
            WHEN m.cvepago IS NOT NULL THEN 'PAGADA'
            ELSE 'PENDIENTE'
        END AS VARCHAR) AS estatus,
        v_total AS total_registros
    FROM comun.multas m
    WHERE
        (p_clave_cuenta = '' OR CAST(m.cvepago AS VARCHAR) = p_clave_cuenta)
    ORDER BY m.fecha_acta DESC, m.id_multa DESC
    OFFSET p_offset
    LIMIT p_limit;
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION comun.recaudadora_multasfrmcalif IS 'Consulta de calificación de multas por cuenta con paginación';
