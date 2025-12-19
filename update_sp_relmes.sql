-- Actualización del Stored Procedure para relmes.vue
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
        WHERE proname = 'recaudadora_relmes'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_relmes(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para relmes (relación mensual de multas por dependencia)
CREATE OR REPLACE FUNCTION publico.recaudadora_relmes(
    p_mes VARCHAR DEFAULT NULL,
    p_anio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    dependencia INTEGER,
    nombre_dependencia VARCHAR,
    cantidad_multas BIGINT,
    total_multas NUMERIC,
    total_gastos NUMERIC,
    total_general NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Usamos tabla h_multasnvo (histórico de multas)
    -- Agrupa por dependencia y calcula totales mensuales

    RETURN QUERY
    SELECT
        r.id_dependencia::INTEGER AS dependencia,
        CASE
            WHEN r.id_dependencia = 1 THEN 'Dependencia 1 - Predial'
            WHEN r.id_dependencia = 3 THEN 'Dependencia 3 - Tránsito'
            WHEN r.id_dependencia = 5 THEN 'Dependencia 5 - Obras'
            WHEN r.id_dependencia = 7 THEN 'Dependencia 7 - Reglamentos'
            WHEN r.id_dependencia = 35 THEN 'Dependencia 35 - Via Pública'
            ELSE 'Dependencia ' || r.id_dependencia::VARCHAR
        END::VARCHAR AS nombre_dependencia,
        COUNT(*)::BIGINT AS cantidad_multas,
        COALESCE(SUM(r.multa), 0) AS total_multas,
        COALESCE(SUM(r.gastos), 0) AS total_gastos,
        COALESCE(SUM(r.total), 0) AS total_general
    FROM public.h_multasnvo r
    WHERE
        r.fecha_acta IS NOT NULL
        AND r.id_dependencia IS NOT NULL
        -- Filtro por año
        AND (p_anio IS NULL OR EXTRACT(YEAR FROM r.fecha_acta) = p_anio)
        -- Filtro por mes (si se proporciona)
        AND (p_mes IS NULL OR p_mes = '' OR EXTRACT(MONTH FROM r.fecha_acta) = p_mes::INTEGER)
    GROUP BY r.id_dependencia
    ORDER BY r.id_dependencia;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_relmes -> Retorna relación mensual de multas por dependencia
--
-- TABLA BASE: public.h_multasnvo (626,583 registros de multas históricas)
--
-- CAMPOS RETORNADOS:
-- - dependencia: ID de la dependencia
-- - nombre_dependencia: Nombre descriptivo de la dependencia
-- - cantidad_multas: Número de multas en el periodo
-- - total_multas: Suma de montos de multas
-- - total_gastos: Suma de gastos de ejecución
-- - total_general: Suma total (multas + gastos)
--
-- PARÁMETROS:
-- - p_mes: VARCHAR (mes 1-12, NULL o '' para todos los meses del año)
-- - p_anio: INTEGER (año, ejemplo: 2024)
--
-- MAPEO DE CAMPOS:
-- - id_dependencia -> dependencia
-- - id_dependencia -> nombre_dependencia (construido)
-- - COUNT(*) -> cantidad_multas
-- - SUM(multa) -> total_multas
-- - SUM(gastos) -> total_gastos
-- - SUM(total) -> total_general
--
-- DEPENDENCIAS PRINCIPALES:
-- - Dependencia 1: Predial
-- - Dependencia 3: Tránsito
-- - Dependencia 5: Obras
-- - Dependencia 7: Reglamentos (mayoría)
-- - Dependencia 35: Vía Pública
--
-- EJEMPLOS DE USO:
--
-- 1. Relación anual (todos los meses de 2024):
-- SELECT * FROM publico.recaudadora_relmes(NULL, 2024);
--
-- 2. Relación mensual específica (enero 2024):
-- SELECT * FROM publico.recaudadora_relmes('1', 2024);
--
-- 3. Relación de un mes específico (junio 2024):
-- SELECT * FROM publico.recaudadora_relmes('6', 2024);
--
-- 4. Todos los datos de 2023:
-- SELECT * FROM publico.recaudadora_relmes('', 2023);
