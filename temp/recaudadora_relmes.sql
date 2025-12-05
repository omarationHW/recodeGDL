-- ================================================================
-- SP: recaudadora_relmes
-- Módulo: multas_reglamentos
-- Descripción: Relación mensual de multas por dependencia
-- Parámetros:
--   p_mes: Mes (1-12), si es vacío o NULL devuelve todo el año
--   p_anio: Año (requerido)
-- ================================================================

DROP FUNCTION IF EXISTS public.recaudadora_relmes(TEXT, INTEGER);

CREATE OR REPLACE FUNCTION public.recaudadora_relmes(
    p_mes TEXT DEFAULT '',
    p_anio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    dependencia SMALLINT,
    nombre_dependencia TEXT,
    cantidad_multas BIGINT,
    total_multas NUMERIC,
    total_gastos NUMERIC,
    total_general NUMERIC,
    mes_reportado INTEGER,
    anio_reportado INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_mes INTEGER;
    v_anio INTEGER;
    v_tiene_mes BOOLEAN;
BEGIN
    -- Validar y convertir mes
    v_mes := NULLIF(TRIM(p_mes), '')::INTEGER;
    v_tiene_mes := v_mes IS NOT NULL AND v_mes BETWEEN 1 AND 12;

    -- Año por defecto es el actual
    v_anio := COALESCE(p_anio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

    -- Si tiene mes específico, filtrar por ese mes
    IF v_tiene_mes THEN
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
                ELSE 'OTRAS DEP.'
            END::TEXT AS nombre_dependencia,
            COUNT(*)::BIGINT AS cantidad_multas,
            COALESCE(SUM(m.multa), 0)::NUMERIC AS total_multas,
            COALESCE(SUM(m.gastos), 0)::NUMERIC AS total_gastos,
            COALESCE(SUM(m.total), 0)::NUMERIC AS total_general,
            v_mes AS mes_reportado,
            v_anio AS anio_reportado
        FROM comun.multas m
        WHERE EXTRACT(YEAR FROM m.fecha_acta) = v_anio
        AND EXTRACT(MONTH FROM m.fecha_acta) = v_mes
        AND m.fecha_acta IS NOT NULL
        GROUP BY m.id_dependencia
        ORDER BY cantidad_multas DESC
        LIMIT 100;

    -- Si NO tiene mes, devolver resumen anual
    ELSE
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
                ELSE 'OTRAS DEP.'
            END::TEXT AS nombre_dependencia,
            COUNT(*)::BIGINT AS cantidad_multas,
            COALESCE(SUM(m.multa), 0)::NUMERIC AS total_multas,
            COALESCE(SUM(m.gastos), 0)::NUMERIC AS total_gastos,
            COALESCE(SUM(m.total), 0)::NUMERIC AS total_general,
            NULL::INTEGER AS mes_reportado,
            v_anio AS anio_reportado
        FROM comun.multas m
        WHERE EXTRACT(YEAR FROM m.fecha_acta) = v_anio
        AND m.fecha_acta IS NOT NULL
        GROUP BY m.id_dependencia
        ORDER BY cantidad_multas DESC
        LIMIT 100;
    END IF;

END;
$$;

COMMENT ON FUNCTION public.recaudadora_relmes(TEXT, INTEGER) IS 'Relación mensual o anual de multas por dependencia';
