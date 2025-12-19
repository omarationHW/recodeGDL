-- Actualización del Stored Procedure para pres.vue
-- Usando la tabla auditoria para simular presupuesto devengado

-- Eliminar TODAS las versiones existentes de la función
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN
        SELECT proname, oidvectortypes(proargtypes) as args
        FROM pg_proc
        INNER JOIN pg_namespace ON pg_proc.pronamespace = pg_namespace.oid
        WHERE proname = 'recaudadora_pres'
        AND nspname = 'publico'
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS publico.recaudadora_pres(' || r.args || ') CASCADE';
    END LOOP;
END $$;

-- Función principal para pres (presupuesto devengado)
-- Usa la tabla auditoria para simular datos presupuestarios
CREATE OR REPLACE FUNCTION publico.recaudadora_pres(
    p_filtro VARCHAR DEFAULT ''
)
RETURNS TABLE (
    ejercicio INTEGER,
    titulo VARCHAR,
    capitulo VARCHAR,
    cta_aplicacion VARCHAR,
    fecha_ingreso DATE,
    presup_anual NUMERIC,
    ingreso_total NUMERIC,
    enero NUMERIC,
    febrero NUMERIC,
    marzo NUMERIC,
    abril NUMERIC,
    mayo NUMERIC,
    junio NUMERIC,
    julio NUMERIC,
    agosto NUMERIC,
    septiembre NUMERIC,
    octubre NUMERIC,
    noviembre NUMERIC,
    diciembre NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    WITH datos_bimestrales AS (
        SELECT
            a.axopago::INTEGER AS ejercicio,
            a.cvectaapl,
            a.bimini,
            SUM(a.monto) AS monto_bimestre
        FROM public.auditoria a
        WHERE
            a.axopago > 1990  -- Excluir años inválidos
            AND a.axopago < 2100
            AND a.cancelacion IS DISTINCT FROM 'C'  -- Excluir cancelados
            AND a.cvectaapl IS NOT NULL
            AND (
                p_filtro = ''
                OR p_filtro IS NULL
                OR a.axopago::TEXT ILIKE '%' || p_filtro || '%'
            )
        GROUP BY a.axopago, a.cvectaapl, a.bimini
    ),
    datos_mensuales AS (
        SELECT
            db.ejercicio,
            db.cvectaapl,
            -- Dividir cada bimestre en 2 meses (cada mes recibe la mitad del monto bimestral)
            SUM(CASE WHEN db.bimini = 1 THEN db.monto_bimestre / 2 ELSE 0 END) AS enero,
            SUM(CASE WHEN db.bimini = 1 THEN db.monto_bimestre / 2 ELSE 0 END) AS febrero,
            SUM(CASE WHEN db.bimini = 2 THEN db.monto_bimestre / 2 ELSE 0 END) AS marzo,
            SUM(CASE WHEN db.bimini = 2 THEN db.monto_bimestre / 2 ELSE 0 END) AS abril,
            SUM(CASE WHEN db.bimini = 3 THEN db.monto_bimestre / 2 ELSE 0 END) AS mayo,
            SUM(CASE WHEN db.bimini = 3 THEN db.monto_bimestre / 2 ELSE 0 END) AS junio,
            SUM(CASE WHEN db.bimini = 4 THEN db.monto_bimestre / 2 ELSE 0 END) AS julio,
            SUM(CASE WHEN db.bimini = 4 THEN db.monto_bimestre / 2 ELSE 0 END) AS agosto,
            SUM(CASE WHEN db.bimini = 5 THEN db.monto_bimestre / 2 ELSE 0 END) AS septiembre,
            SUM(CASE WHEN db.bimini = 5 THEN db.monto_bimestre / 2 ELSE 0 END) AS octubre,
            SUM(CASE WHEN db.bimini = 6 THEN db.monto_bimestre / 2 ELSE 0 END) AS noviembre,
            SUM(CASE WHEN db.bimini = 6 THEN db.monto_bimestre / 2 ELSE 0 END) AS diciembre,
            SUM(db.monto_bimestre) AS total_anual
        FROM datos_bimestrales db
        GROUP BY db.ejercicio, db.cvectaapl
    )
    SELECT
        dm.ejercicio,
        'Movimientos de Auditoria'::VARCHAR AS titulo,
        'Cuenta Aplicación'::VARCHAR AS capitulo,
        dm.cvectaapl::VARCHAR AS cta_aplicacion,
        MAKE_DATE(dm.ejercicio, 1, 1) AS fecha_ingreso,
        dm.total_anual AS presup_anual,
        dm.total_anual AS ingreso_total,
        dm.enero,
        dm.febrero,
        dm.marzo,
        dm.abril,
        dm.mayo,
        dm.junio,
        dm.julio,
        dm.agosto,
        dm.septiembre,
        dm.octubre,
        dm.noviembre,
        dm.diciembre
    FROM datos_mensuales dm
    WHERE dm.total_anual != 0  -- Excluir cuentas sin movimientos
    ORDER BY dm.ejercicio DESC, dm.total_anual DESC;

END;
$$;

-- Comentarios sobre la función:
-- publico.recaudadora_pres -> Retorna presupuesto devengado desde tabla auditoria
--
-- IMPORTANTE:
-- - Esta función usa la tabla public.auditoria (29.5M registros)
-- - Simula presupuesto devengado desde movimientos de auditoría
-- - Convierte datos bimestrales a mensuales (divide entre 2)
-- - Permite filtrar por ejercicio
-- - Estructura de retorno:
--   * ejercicio: Año fiscal (axopago)
--   * titulo: 'Movimientos de Auditoria' (fijo)
--   * capitulo: 'Cuenta Aplicación' (fijo)
--   * cta_aplicacion: Código de cuenta (cvectaapl)
--   * fecha_ingreso: 1 de enero del ejercicio
--   * presup_anual: Suma anual total
--   * ingreso_total: Igual que presup_anual
--   * enero-diciembre: Montos mensuales (derivados de bimestres)
--
-- CONVERSIÓN BIMESTRAL A MENSUAL:
-- - Bimestre 1 (Ene-Feb) → Divide monto entre 2 para enero y febrero
-- - Bimestre 2 (Mar-Abr) → Divide monto entre 2 para marzo y abril
-- - Bimestre 3 (May-Jun) → Divide monto entre 2 para mayo y junio
-- - Bimestre 4 (Jul-Ago) → Divide monto entre 2 para julio y agosto
-- - Bimestre 5 (Sep-Oct) → Divide monto entre 2 para septiembre y octubre
-- - Bimestre 6 (Nov-Dic) → Divide monto entre 2 para noviembre y diciembre
--
-- NOTAS:
-- - Los datos NO son presupuesto real, son movimientos de auditoría
-- - Se usa para aproximar un reporte de presupuesto devengado
-- - Datos desde 1991 hasta 2024
-- - Filtro por ejercicio usando ILIKE
-- - Excluye movimientos cancelados
-- - Excluye años inválidos (< 1990 o > 2100)
--
-- ESTADÍSTICAS:
-- - Años disponibles: 1991-2024
-- - Cuentas por año: Variable (ejemplo: 2024 tiene 6 cuentas principales)
-- - Total anual ejemplo 2024: ~$1.4B distribuido en 12 meses
--
-- EJEMPLO DE USO:
-- SELECT * FROM publico.recaudadora_pres('');  -- Todos los ejercicios
-- SELECT * FROM publico.recaudadora_pres('2024');  -- Solo 2024
-- SELECT * FROM publico.recaudadora_pres('202');  -- Años que contienen '202' (2020-2024)
