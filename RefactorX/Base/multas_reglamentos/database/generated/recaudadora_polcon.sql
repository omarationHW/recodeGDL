-- ================================================================
-- SP: recaudadora_polcon
-- Módulo: multas_reglamentos
-- Autor: Sistema RefactorX
-- Fecha: 2025-12-04
-- Descripción: Póliza Diaria Consolidada de las Recaudadoras
--              Muestra el resumen de pólizas agrupado por cuenta de aplicación
-- ================================================================

CREATE OR REPLACE FUNCTION db_ingresos.recaudadora_polcon(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE (
    cvectaapl INTEGER,
    ctaaplicacion VARCHAR,
    totpar NUMERIC,
    suma NUMERIC,
    num_movimientos INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Si no se proporcionan fechas, usar el día actual
    IF p_fecha_desde IS NULL THEN
        p_fecha_desde := CURRENT_DATE;
    END IF;

    IF p_fecha_hasta IS NULL THEN
        p_fecha_hasta := CURRENT_DATE;
    END IF;

    -- Retornar pólizas consolidadas agrupadas por cuenta de aplicación
    RETURN QUERY
    SELECT
        m.cta_aplicacion AS cvectaapl,
        TRIM(COALESCE(m.concepto, 'Sin concepto'))::VARCHAR AS ctaaplicacion,
        SUM(1)::NUMERIC AS totpar,  -- Total de partidas (movimientos)
        SUM(COALESCE(m.cargo, 0) - COALESCE(m.abono, 0))::NUMERIC AS suma,  -- Suma neta (cargo - abono)
        COUNT(*)::INTEGER AS num_movimientos
    FROM db_ingresos.cg_polizas p
    INNER JOIN db_ingresos.cg_poliza_movimientos m ON p.id_poliza = m.id_poliza
    WHERE
        p.fecha BETWEEN p_fecha_desde AND p_fecha_hasta
        AND m.cta_aplicacion IS NOT NULL
    GROUP BY m.cta_aplicacion, m.concepto
    ORDER BY m.cta_aplicacion, suma DESC
    LIMIT 1000; -- Límite de seguridad

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION db_ingresos.recaudadora_polcon(DATE, DATE) IS
'Póliza Diaria Consolidada de las Recaudadoras. Retorna el resumen de pólizas agrupado por cuenta de aplicación para un rango de fechas. Parámetros: p_fecha_desde (opcional), p_fecha_hasta (opcional)';
