-- Actualización del Stored Procedure para repavance.vue
-- Reporte de Avance por rango de fechas
-- Usando tabla h_multasnvo (histórico de multas)

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_repavance'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_repavance(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para reporte de avance
CREATE OR REPLACE FUNCTION publico.recaudadora_repavance(
    p_desde DATE,
    p_hasta DATE
)
RETURNS TABLE (
    dependencia INTEGER,
    nombre_dependencia VARCHAR,
    cantidad_multas BIGINT,
    total_multas NUMERIC,
    total_gastos NUMERIC,
    total_general NUMERIC,
    promedio_multa NUMERIC,
    porcentaje_total NUMERIC
)
LANGUAGE plpgsql AS $$
DECLARE
    v_total_general NUMERIC;
BEGIN
    -- Validar fechas
    IF p_desde IS NULL OR p_hasta IS NULL THEN
        RAISE EXCEPTION 'Las fechas desde y hasta son requeridas';
    END IF;

    IF p_desde > p_hasta THEN
        RAISE EXCEPTION 'La fecha desde no puede ser mayor que la fecha hasta';
    END IF;

    -- Calcular el total general para el cálculo de porcentajes
    SELECT COALESCE(SUM(total), 0)
    INTO v_total_general
    FROM public.h_multasnvo r
    WHERE r.fecha_acta IS NOT NULL
        AND r.id_dependencia IS NOT NULL
        AND r.fecha_acta >= p_desde
        AND r.fecha_acta <= p_hasta;

    -- Usamos tabla h_multasnvo (histórico de multas)
    -- Agrupa por dependencia y calcula totales en el rango de fechas

    RETURN QUERY
    SELECT
        r.id_dependencia::INTEGER AS dependencia,
        CASE
            WHEN r.id_dependencia = 1 THEN 'Dependencia 1 - Predial'
            WHEN r.id_dependencia = 3 THEN 'Dependencia 3 - Tránsito'
            WHEN r.id_dependencia = 5 THEN 'Dependencia 5 - Obras'
            WHEN r.id_dependencia = 6 THEN 'Dependencia 6'
            WHEN r.id_dependencia = 7 THEN 'Dependencia 7 - Reglamentos'
            WHEN r.id_dependencia = 35 THEN 'Dependencia 35 - Vía Pública'
            ELSE 'Dependencia ' || r.id_dependencia::VARCHAR
        END::VARCHAR AS nombre_dependencia,
        COUNT(*)::BIGINT AS cantidad_multas,
        COALESCE(SUM(r.multa), 0) AS total_multas,
        COALESCE(SUM(r.gastos), 0) AS total_gastos,
        COALESCE(SUM(r.total), 0) AS total_general,
        CASE
            WHEN COUNT(*) > 0 THEN ROUND(COALESCE(SUM(r.total), 0) / COUNT(*), 2)
            ELSE 0
        END AS promedio_multa,
        CASE
            WHEN v_total_general > 0 THEN ROUND((COALESCE(SUM(r.total), 0) / v_total_general) * 100, 2)
            ELSE 0
        END AS porcentaje_total
    FROM public.h_multasnvo r
    WHERE
        r.fecha_acta IS NOT NULL
        AND r.id_dependencia IS NOT NULL
        -- Filtro por rango de fechas
        AND r.fecha_acta >= p_desde
        AND r.fecha_acta <= p_hasta
    GROUP BY r.id_dependencia
    ORDER BY total_general DESC;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_repavance(p_desde, p_hasta) -> Retorna reporte de avance por rango de fechas
--
-- TABLA BASE: public.h_multasnvo (626,583 registros de multas históricas)
--
-- CAMPOS RETORNADOS:
-- - dependencia: INTEGER (ID de la dependencia)
-- - nombre_dependencia: VARCHAR (nombre descriptivo de la dependencia)
-- - cantidad_multas: BIGINT (número de multas en el periodo)
-- - total_multas: NUMERIC (suma de montos de multas)
-- - total_gastos: NUMERIC (suma de gastos de ejecución)
-- - total_general: NUMERIC (suma total: multas + gastos)
-- - promedio_multa: NUMERIC (promedio por multa)
-- - porcentaje_total: NUMERIC (porcentaje sobre el total)
--
-- PARÁMETROS:
-- - p_desde: DATE (fecha inicial del rango)
-- - p_hasta: DATE (fecha final del rango)
--
-- AGREGACIÓN:
-- - Por dependencia en el rango de fechas
-- - Totales por dependencia
-- - Promedio calculado por dependencia
-- - Porcentaje calculado sobre el total del periodo
--
-- VALIDACIONES:
-- - Ambas fechas son requeridas
-- - La fecha desde no puede ser mayor que hasta
--
-- EJEMPLOS DE USO:
--
-- 1. Reporte de avance del mes de enero 2024:
-- SELECT * FROM publico.recaudadora_repavance('2024-01-01', '2024-01-31');
--
-- 2. Reporte de avance del primer trimestre 2024:
-- SELECT * FROM publico.recaudadora_repavance('2024-01-01', '2024-03-31');
--
-- 3. Reporte de avance del año completo 2024:
-- SELECT * FROM publico.recaudadora_repavance('2024-01-01', '2024-12-31');
--
-- 4. Reporte de avance personalizado (últimos 30 días):
-- SELECT * FROM publico.recaudadora_repavance(CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE);
