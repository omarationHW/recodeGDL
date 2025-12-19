-- Actualización del Stored Procedure para repmultampalfrm.vue
-- Reporte de Multas Municipales agregado por mes
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
        WHERE proname = 'recaudadora_repmultampalfrm'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_repmultampalfrm(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para reporte de multas municipales
CREATE OR REPLACE FUNCTION publico.recaudadora_repmultampalfrm(
    p_ejercicio INTEGER
)
RETURNS TABLE (
    mes INTEGER,
    nombre_mes VARCHAR,
    cantidad_multas BIGINT,
    total_multas NUMERIC,
    total_gastos NUMERIC,
    total_general NUMERIC,
    promedio_multa NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Usamos tabla h_multasnvo (histórico de multas)
    -- Agrupa por mes y calcula totales del ejercicio fiscal

    RETURN QUERY
    SELECT
        EXTRACT(MONTH FROM r.fecha_acta)::INTEGER AS mes,
        CASE EXTRACT(MONTH FROM r.fecha_acta)::INTEGER
            WHEN 1 THEN 'Enero'
            WHEN 2 THEN 'Febrero'
            WHEN 3 THEN 'Marzo'
            WHEN 4 THEN 'Abril'
            WHEN 5 THEN 'Mayo'
            WHEN 6 THEN 'Junio'
            WHEN 7 THEN 'Julio'
            WHEN 8 THEN 'Agosto'
            WHEN 9 THEN 'Septiembre'
            WHEN 10 THEN 'Octubre'
            WHEN 11 THEN 'Noviembre'
            WHEN 12 THEN 'Diciembre'
            ELSE 'Desconocido'
        END::VARCHAR AS nombre_mes,
        COUNT(*)::BIGINT AS cantidad_multas,
        COALESCE(SUM(r.multa), 0) AS total_multas,
        COALESCE(SUM(r.gastos), 0) AS total_gastos,
        COALESCE(SUM(r.total), 0) AS total_general,
        CASE
            WHEN COUNT(*) > 0 THEN ROUND(COALESCE(SUM(r.total), 0) / COUNT(*), 2)
            ELSE 0
        END AS promedio_multa
    FROM public.h_multasnvo r
    WHERE
        r.fecha_acta IS NOT NULL
        -- Filtro por ejercicio fiscal (año)
        AND EXTRACT(YEAR FROM r.fecha_acta) = p_ejercicio
    GROUP BY EXTRACT(MONTH FROM r.fecha_acta)
    ORDER BY mes;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_repmultampalfrm(p_ejercicio) -> Retorna reporte mensual de multas municipales
--
-- TABLA BASE: public.h_multasnvo (626,583 registros de multas históricas)
--
-- CAMPOS RETORNADOS:
-- - mes: INTEGER (número del mes 1-12)
-- - nombre_mes: VARCHAR (nombre del mes en español)
-- - cantidad_multas: BIGINT (número de multas en el mes)
-- - total_multas: NUMERIC (suma de montos de multas)
-- - total_gastos: NUMERIC (suma de gastos de ejecución)
-- - total_general: NUMERIC (suma total: multas + gastos)
-- - promedio_multa: NUMERIC (promedio por multa en el mes)
--
-- PARÁMETROS:
-- - p_ejercicio: INTEGER (año del ejercicio fiscal, ejemplo: 2024)
--
-- AGREGACIÓN:
-- - Por mes del ejercicio fiscal
-- - Totales por mes
-- - Promedio calculado por mes
--
-- EJEMPLOS DE USO:
--
-- 1. Reporte mensual del ejercicio 2024:
-- SELECT * FROM publico.recaudadora_repmultampalfrm(2024);
--
-- 2. Reporte mensual del ejercicio 2023:
-- SELECT * FROM publico.recaudadora_repmultampalfrm(2023);
--
-- 3. Comparar ejercicios:
-- SELECT 2024 as ejercicio, * FROM publico.recaudadora_repmultampalfrm(2024)
-- UNION ALL
-- SELECT 2023 as ejercicio, * FROM publico.recaudadora_repmultampalfrm(2023);
