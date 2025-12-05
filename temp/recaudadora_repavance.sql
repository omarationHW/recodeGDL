-- ================================================================
-- SP: recaudadora_repavance
-- Módulo: multas_reglamentos
-- Descripción: Reporte de avance de multas por dependencia en un rango de fechas
-- Parámetros:
--   p_desde: Fecha inicial (requerido)
--   p_hasta: Fecha final (requerido)
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_repavance(DATE, DATE);

CREATE OR REPLACE FUNCTION public.recaudadora_repavance(
    p_desde DATE,
    p_hasta DATE
)
RETURNS TABLE (
    dependencia SMALLINT,
    nombre_dependencia TEXT,
    cantidad_multas BIGINT,
    total_multas NUMERIC,
    total_gastos NUMERIC,
    total_general NUMERIC,
    fecha_desde DATE,
    fecha_hasta DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_desde DATE;
    v_hasta DATE;
BEGIN
    -- Validar fechas
    v_desde := p_desde;
    v_hasta := p_hasta;

    -- Si las fechas son NULL, usar rango amplio
    IF v_desde IS NULL THEN
        v_desde := '2020-01-01';
    END IF;

    IF v_hasta IS NULL THEN
        v_hasta := CURRENT_DATE;
    END IF;

    -- Validar que desde <= hasta
    IF v_desde > v_hasta THEN
        RAISE EXCEPTION 'La fecha inicial no puede ser mayor que la fecha final';
    END IF;

    RETURN QUERY
    SELECT
        m.id_dependencia AS dependencia,
        CASE m.id_dependencia
            WHEN 1 THEN 'TESORERIA'
            WHEN 3 THEN 'TRANSITO'
            WHEN 4 THEN 'MERCADOS'
            WHEN 5 THEN 'OBRAS PUBLICAS'
            WHEN 6 THEN 'DESARROLLO URBANO'
            WHEN 7 THEN 'REGLAMENTOS'
            WHEN 8 THEN 'RASTRO'
            WHEN 25 THEN 'ATENCION CIUDADANA'
            WHEN 35 THEN 'ECOLOGIA'
            ELSE 'OTRAS DEPENDENCIAS'
        END::TEXT AS nombre_dependencia,
        COUNT(*)::BIGINT AS cantidad_multas,
        COALESCE(SUM(m.multa), 0)::NUMERIC AS total_multas,
        COALESCE(SUM(m.gastos), 0)::NUMERIC AS total_gastos,
        COALESCE(SUM(m.total), 0)::NUMERIC AS total_general,
        v_desde AS fecha_desde,
        v_hasta AS fecha_hasta
    FROM comun.multas m
    WHERE DATE(m.fecha_acta) >= v_desde
    AND DATE(m.fecha_acta) <= v_hasta
    AND m.fecha_acta IS NOT NULL
    GROUP BY m.id_dependencia
    ORDER BY cantidad_multas DESC
    LIMIT 100;

END;
$$;

COMMENT ON FUNCTION public.recaudadora_repavance(DATE, DATE) IS 'Reporte de avance de multas por dependencia en un rango de fechas';
