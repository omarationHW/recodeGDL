-- ================================================================
-- SP: recaudadora_repmultampalfrm
-- Módulo: multas_reglamentos
-- Descripción: Reporte de multas municipales por dependencia por ejercicio
-- Parámetros:
--   p_ejercicio: Año del ejercicio (requerido)
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_repmultampalfrm(INTEGER);

CREATE OR REPLACE FUNCTION public.recaudadora_repmultampalfrm(
    p_ejercicio INTEGER
)
RETURNS TABLE (
    dependencia SMALLINT,
    nombre_dependencia TEXT,
    cantidad_multas BIGINT,
    total_multas NUMERIC,
    total_gastos NUMERIC,
    total_general NUMERIC,
    ejercicio INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ejercicio INTEGER;
BEGIN
    -- Validar ejercicio
    v_ejercicio := COALESCE(p_ejercicio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

    -- Validar rango razonable
    IF v_ejercicio < 2000 OR v_ejercicio > 2050 THEN
        RAISE EXCEPTION 'El ejercicio debe estar entre 2000 y 2050';
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
        v_ejercicio AS ejercicio
    FROM comun.multas m
    WHERE m.axo_acta = v_ejercicio
    GROUP BY m.id_dependencia
    ORDER BY cantidad_multas DESC
    LIMIT 100;

END;
$$;

COMMENT ON FUNCTION public.recaudadora_repmultampalfrm(INTEGER) IS 'Reporte de multas municipales por dependencia por ejercicio';
