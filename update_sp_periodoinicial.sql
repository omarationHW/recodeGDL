-- Actualización del Stored Procedure para PeriodoInicial.vue
-- Como no existe la tabla parametros_sistema, retorna valores predeterminados

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_periodo_inicial'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_periodo_inicial(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para PeriodoInicial
CREATE OR REPLACE FUNCTION publico.recaudadora_periodo_inicial(
    p_ejercicio INTEGER DEFAULT NULL
)
RETURNS TABLE (
    municipio VARCHAR,
    ejercicio INTEGER,
    bimestre_inicial SMALLINT,
    año_inicial INTEGER,
    bimestre_fin SMALLINT,
    año_final INTEGER,
    director VARCHAR,
    tesorero VARCHAR,
    presidente VARCHAR,
    salario NUMERIC,
    aplica_descuento_recargo BOOLEAN
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Como no existe la tabla parametros_sistema, retornamos valores predeterminados
    -- basados en el ejercicio solicitado o el año actual

    RETURN QUERY
    SELECT
        'Guadalajara'::VARCHAR AS municipio,
        COALESCE(p_ejercicio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER) AS ejercicio,
        1::SMALLINT AS bimestre_inicial,
        COALESCE(p_ejercicio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER) AS año_inicial,
        6::SMALLINT AS bimestre_final,
        COALESCE(p_ejercicio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER) AS año_final,
        'N/A'::VARCHAR AS director,
        'N/A'::VARCHAR AS tesorero,
        'N/A'::VARCHAR AS presidente,
        0::NUMERIC AS salario,
        true::BOOLEAN AS aplica_descuento_recargo;

END;
$$;

-- Comentarios sobre la función:
-- public.recaudadora_periodo_inicial -> Retorna parámetros del sistema predeterminados
--
-- IMPORTANTE:
-- - Esta función retorna valores predeterminados porque la tabla parametros_sistema no existe
-- - municipio: Valor fijo 'Guadalajara'
-- - ejercicio: El solicitado o el año actual
-- - bimestre_inicial: Siempre 1 (Ene-Feb)
-- - año_inicial: Mismo que ejercicio
-- - bimestre_final: Siempre 6 (Nov-Dic)
-- - año_final: Mismo que ejercicio
-- - director, tesorero, presidente: 'N/A' (no disponibles)
-- - salario: 0 (no disponible)
-- - aplica_descuento_recargo: true (valor predeterminado)
--
-- NOTA:
-- Si se requiere mantener valores reales de configuración del sistema,
-- se debe crear la tabla parametros_sistema con estos campos:
--   - municipio VARCHAR
--   - ejercicio INTEGER
--   - bimestre_inicial SMALLINT
--   - año_inicial INTEGER
--   - bimestre_final SMALLINT
--   - año_final INTEGER
--   - director VARCHAR
--   - tesorero VARCHAR
--   - presidente VARCHAR
--   - salario NUMERIC
--   - aplica_descuento_recargo BOOLEAN
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_periodo_inicial(NULL);  -- Año actual
-- SELECT * FROM publico.recaudadora_periodo_inicial(2024);  -- Ejercicio 2024
-- SELECT * FROM publico.recaudadora_periodo_inicial(2023);  -- Ejercicio 2023
