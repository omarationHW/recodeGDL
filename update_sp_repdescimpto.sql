-- Actualización del Stored Procedure para RepDescImpto.vue
-- Usando tabla h_multasnvo (histórico de multas) en lugar de relacion_mensual

-- Eliminar la versión con parámetro integer
DROP FUNCTION IF EXISTS publico.recaudadora_rep_desc_impto(INTEGER) CASCADE;

-- Crear función actualizada para reporte de descuentos por impuesto
CREATE OR REPLACE FUNCTION publico.recaudadora_rep_desc_impto(
    p_ejercicio INTEGER
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
    -- Agrupa por dependencia para un ejercicio fiscal completo (año)

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
        COALESCE(SUM(r.total), 0) AS total_general
    FROM public.h_multasnvo r
    WHERE
        r.fecha_acta IS NOT NULL
        AND r.id_dependencia IS NOT NULL
        -- Filtro por ejercicio fiscal (año)
        AND EXTRACT(YEAR FROM r.fecha_acta) = p_ejercicio
    GROUP BY r.id_dependencia
    ORDER BY r.id_dependencia;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_rep_desc_impto(p_ejercicio) -> Retorna reporte anual de multas por dependencia
--
-- TABLA BASE: public.h_multasnvo (626,583 registros de multas históricas)
--
-- CAMPOS RETORNADOS:
-- - dependencia: ID de la dependencia
-- - nombre_dependencia: Nombre descriptivo de la dependencia
-- - cantidad_multas: Número de multas en el ejercicio fiscal
-- - total_multas: Suma de montos de multas
-- - total_gastos: Suma de gastos de ejecución
-- - total_general: Suma total (multas + gastos)
--
-- PARÁMETROS:
-- - p_ejercicio: INTEGER (año del ejercicio fiscal, ejemplo: 2024)
--
-- MAPEO DE CAMPOS:
-- - id_dependencia -> dependencia
-- - id_dependencia -> nombre_dependencia (construido con CASE)
-- - COUNT(*) -> cantidad_multas
-- - SUM(multa) -> total_multas
-- - SUM(gastos) -> total_gastos
-- - SUM(total) -> total_general
-- - EXTRACT(YEAR FROM fecha_acta) para filtrar por ejercicio
--
-- DEPENDENCIAS PRINCIPALES:
-- - Dependencia 1: Predial
-- - Dependencia 3: Tránsito
-- - Dependencia 5: Obras (mayor recaudación)
-- - Dependencia 7: Reglamentos
-- - Dependencia 35: Vía Pública
--
-- EJEMPLOS DE USO:
--
-- 1. Reporte del ejercicio fiscal 2024:
-- SELECT * FROM publico.recaudadora_rep_desc_impto(2024);
--
-- 2. Reporte del ejercicio fiscal 2023:
-- SELECT * FROM publico.recaudadora_rep_desc_impto(2023);
--
-- 3. Comparar ejercicios fiscales:
-- SELECT 2024 as ejercicio, * FROM publico.recaudadora_rep_desc_impto(2024)
-- UNION ALL
-- SELECT 2023 as ejercicio, * FROM publico.recaudadora_rep_desc_impto(2023);
