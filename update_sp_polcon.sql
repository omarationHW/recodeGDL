-- Actualización del Stored Procedure para polcon.vue
-- Usando la tabla auditoria que tiene 29.5 millones de registros

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_polcon'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_polcon(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para polcon (pólizas consolidadas)
-- Usa la tabla auditoria para agregar movimientos contables
CREATE OR REPLACE FUNCTION publico.recaudadora_polcon(
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL
)
RETURNS TABLE (
    cvectaapl VARCHAR,
    ctaaplicacion VARCHAR,
    totpar BIGINT,
    suma NUMERIC,
    num_movimientos BIGINT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_anio_desde SMALLINT;
    v_anio_hasta SMALLINT;
BEGIN
    -- Extraer años de las fechas para filtrar
    IF p_fecha_desde IS NOT NULL THEN
        v_anio_desde := EXTRACT(YEAR FROM p_fecha_desde)::SMALLINT;
    END IF;

    IF p_fecha_hasta IS NOT NULL THEN
        v_anio_hasta := EXTRACT(YEAR FROM p_fecha_hasta)::SMALLINT;
    END IF;

    -- Agregar datos de la tabla auditoria por cvectaapl
    RETURN QUERY
    SELECT
        a.cvectaapl::VARCHAR AS cvectaapl,
        ('Cuenta Aplicación ' || a.cvectaapl::VARCHAR)::VARCHAR AS ctaaplicacion,
        COUNT(DISTINCT a.cvepago)::BIGINT AS totpar,
        SUM(a.monto) AS suma,
        COUNT(*)::BIGINT AS num_movimientos
    FROM public.auditoria a
    WHERE
        a.cvectaapl IS NOT NULL
        AND a.cancelacion IS DISTINCT FROM 'C'  -- Excluir cancelados
        AND (
            -- Si no hay filtros de fecha, traer todo
            (v_anio_desde IS NULL AND v_anio_hasta IS NULL)
            OR (
                -- Si hay filtros, solo incluir registros con axopago válido
                a.axopago IS NOT NULL
                AND (v_anio_desde IS NULL OR a.axopago >= v_anio_desde)
                AND (v_anio_hasta IS NULL OR a.axopago <= v_anio_hasta)
            )
        )
    GROUP BY a.cvectaapl
    ORDER BY num_movimientos DESC;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_polcon -> Retorna pólizas consolidadas desde tabla auditoria
--
-- IMPORTANTE:
-- - Esta función usa la tabla public.auditoria (29.5 millones de registros)
-- - Agrupa movimientos contables por cvectaapl (cuenta de aplicación)
-- - Excluye registros cancelados (cancelacion = 'C')
-- - Filtra por año cuando se proporcionan fechas
-- - Estructura de retorno:
--   * cvectaapl: Código de cuenta aplicación
--   * ctaaplicacion: Descripción generada (no hay catálogo)
--   * totpar: Total de pagos únicos (cvepago distintos)
--   * suma: Suma total de montos
--   * num_movimientos: Número total de movimientos
--
-- NOTA SOBRE FILTROS DE FECHA:
-- - La tabla auditoria tiene axopago (año) y bimini (bimestre)
-- - No tiene un campo fecha completo
-- - El filtro extrae el año de las fechas proporcionadas
-- - Si p_fecha_desde = '2024-01-01', filtra axopago >= 2024
-- - Si p_fecha_hasta = '2024-12-31', filtra axopago <= 2024
--
-- ESTADÍSTICAS DE LA TABLA AUDITORIA:
-- - 29,572,443 registros totales
-- - 460 cuentas de aplicación diferentes
-- - 11,633,621 pagos únicos
-- - Años: 1990-2024
-- - Top cvectaapl:
--   * 110110000: 5M movimientos, $10,316M
--   * 40401: 3.5M movimientos, $3,104M
--   * 110120000: 3M movimientos, $2,114M
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_polcon(NULL, NULL);  -- Todos los registros
-- SELECT * FROM publico.recaudadora_polcon('2024-01-01', '2024-12-31');  -- Año 2024
-- SELECT * FROM publico.recaudadora_polcon('2020-01-01', NULL);  -- Desde 2020
