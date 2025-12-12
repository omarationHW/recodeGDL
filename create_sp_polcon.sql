CREATE OR REPLACE FUNCTION publico.recaudadora_polcon(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE (
    cvectaapl VARCHAR,
    ctaaplicacion VARCHAR,
    totpar BIGINT,
    suma NUMERIC,
    num_movimientos BIGINT
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.cvectaapl,
        MAX(p.ctaaplicacion)::VARCHAR AS ctaaplicacion,
        SUM(p.totpar)::BIGINT AS totpar,
        SUM(p.suma) AS suma,
        SUM(p.num_movimientos)::BIGINT AS num_movimientos
    FROM publico.polizas_consolidadas p
    WHERE
        (p_fecha_desde IS NULL OR p.fecha_operacion >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR p.fecha_operacion <= p_fecha_hasta)
    GROUP BY p.cvectaapl
    ORDER BY p.cvectaapl;
END; $$;
