-- =====================================================================================
-- COMPONENTE: REPESTADISTICOSLICFRM - Reportes Estadisticos de Licencias
-- MODULO: padron_licencias
-- FECHA: 2025-11-21
-- DESCRIPCION: Stored Procedures para reportes estadisticos de licencias por zona,
--              giro y periodo. Genera informes ejecutivos.
-- =====================================================================================

-- ====================================================================================
-- SP 1: sp_rep_estadisticos_lic_rango
-- DESCRIPCION: Reporte de licencias por rango de fechas, agrupadas por giro y zona
-- ====================================================================================
DROP FUNCTION IF EXISTS comun.sp_rep_estadisticos_lic_rango(DATE, DATE);

CREATE OR REPLACE FUNCTION comun.sp_rep_estadisticos_lic_rango(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion VARCHAR,
    z_1 INTEGER,
    z_2 INTEGER,
    z_3 INTEGER,
    z_4 INTEGER,
    z_5 INTEGER,
    z_6 INTEGER,
    z_7 INTEGER,
    otros INTEGER,
    total INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_fecha_desde DATE;
    v_fecha_hasta DATE;
BEGIN
    -- Validar y ajustar fechas
    v_fecha_desde := COALESCE(p_fecha_desde, CURRENT_DATE - INTERVAL '1 year');
    v_fecha_hasta := COALESCE(p_fecha_hasta, CURRENT_DATE);

    -- Asegurar orden correcto de fechas
    IF v_fecha_desde > v_fecha_hasta THEN
        v_fecha_desde := p_fecha_hasta;
        v_fecha_hasta := p_fecha_desde;
    END IF;

    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion::VARCHAR,
        COALESCE(COUNT(CASE WHEN l.zona = 1 THEN 1 END), 0)::INTEGER AS z_1,
        COALESCE(COUNT(CASE WHEN l.zona = 2 THEN 1 END), 0)::INTEGER AS z_2,
        COALESCE(COUNT(CASE WHEN l.zona = 3 THEN 1 END), 0)::INTEGER AS z_3,
        COALESCE(COUNT(CASE WHEN l.zona = 4 THEN 1 END), 0)::INTEGER AS z_4,
        COALESCE(COUNT(CASE WHEN l.zona = 5 THEN 1 END), 0)::INTEGER AS z_5,
        COALESCE(COUNT(CASE WHEN l.zona = 6 THEN 1 END), 0)::INTEGER AS z_6,
        COALESCE(COUNT(CASE WHEN l.zona = 7 THEN 1 END), 0)::INTEGER AS z_7,
        COALESCE(COUNT(CASE WHEN l.zona NOT IN (1, 2, 3, 4, 5, 6, 7) OR l.zona IS NULL THEN 1 END), 0)::INTEGER AS otros,
        COALESCE(COUNT(l.id_licencia), 0)::INTEGER AS total
    FROM
        comun.c_giros g
    LEFT JOIN
        comun.licencias l ON g.id_giro = l.id_giro
            AND l.fecha_alta >= v_fecha_desde
            AND l.fecha_alta <= v_fecha_hasta
    GROUP BY
        g.id_giro, g.descripcion
    HAVING
        COUNT(l.id_licencia) > 0
    ORDER BY
        total DESC, g.descripcion;
END;
$$;

COMMENT ON FUNCTION comun.sp_rep_estadisticos_lic_rango(DATE, DATE) IS
'Reporte de licencias por rango de fechas agrupadas por giro y zona (1-7 + otros)';


-- ====================================================================================
-- SP 2: sp_rep_estadisticos_lic_anual
-- DESCRIPCION: Reporte anual de licencias por giro y zona
-- ====================================================================================
DROP FUNCTION IF EXISTS comun.sp_rep_estadisticos_lic_anual(INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_rep_estadisticos_lic_anual(
    p_anio INTEGER DEFAULT NULL
)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion VARCHAR,
    z_1 INTEGER,
    z_2 INTEGER,
    z_3 INTEGER,
    z_4 INTEGER,
    z_5 INTEGER,
    z_6 INTEGER,
    z_7 INTEGER,
    otros INTEGER,
    total INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_anio INTEGER;
    v_fecha_desde DATE;
    v_fecha_hasta DATE;
BEGIN
    -- Si p_anio es NULL, usar anio actual
    v_anio := COALESCE(p_anio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);

    -- Calcular rango de fechas del anio
    v_fecha_desde := make_date(v_anio, 1, 1);
    v_fecha_hasta := make_date(v_anio, 12, 31);

    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion::VARCHAR,
        COALESCE(COUNT(CASE WHEN l.zona = 1 THEN 1 END), 0)::INTEGER AS z_1,
        COALESCE(COUNT(CASE WHEN l.zona = 2 THEN 1 END), 0)::INTEGER AS z_2,
        COALESCE(COUNT(CASE WHEN l.zona = 3 THEN 1 END), 0)::INTEGER AS z_3,
        COALESCE(COUNT(CASE WHEN l.zona = 4 THEN 1 END), 0)::INTEGER AS z_4,
        COALESCE(COUNT(CASE WHEN l.zona = 5 THEN 1 END), 0)::INTEGER AS z_5,
        COALESCE(COUNT(CASE WHEN l.zona = 6 THEN 1 END), 0)::INTEGER AS z_6,
        COALESCE(COUNT(CASE WHEN l.zona = 7 THEN 1 END), 0)::INTEGER AS z_7,
        COALESCE(COUNT(CASE WHEN l.zona NOT IN (1, 2, 3, 4, 5, 6, 7) OR l.zona IS NULL THEN 1 END), 0)::INTEGER AS otros,
        COALESCE(COUNT(l.id_licencia), 0)::INTEGER AS total
    FROM
        comun.c_giros g
    LEFT JOIN
        comun.licencias l ON g.id_giro = l.id_giro
            AND l.fecha_alta >= v_fecha_desde
            AND l.fecha_alta <= v_fecha_hasta
    GROUP BY
        g.id_giro, g.descripcion
    HAVING
        COUNT(l.id_licencia) > 0
    ORDER BY
        total DESC, g.descripcion;
END;
$$;

COMMENT ON FUNCTION comun.sp_rep_estadisticos_lic_anual(INTEGER) IS
'Reporte anual de licencias por giro y zona. Si p_anio es NULL usa el anio actual';


-- ====================================================================================
-- SP 3: sp_rep_estadisticos_lic_mensual
-- DESCRIPCION: Reporte mensual con comparativa del mes anterior
-- ====================================================================================
DROP FUNCTION IF EXISTS comun.sp_rep_estadisticos_lic_mensual(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION comun.sp_rep_estadisticos_lic_mensual(
    p_anio INTEGER,
    p_mes INTEGER
)
RETURNS TABLE(
    id_giro INTEGER,
    descripcion VARCHAR,
    z_1 INTEGER,
    z_2 INTEGER,
    z_3 INTEGER,
    z_4 INTEGER,
    z_5 INTEGER,
    z_6 INTEGER,
    z_7 INTEGER,
    otros INTEGER,
    total INTEGER,
    total_mes_anterior INTEGER,
    variacion_porcentaje NUMERIC(10,2)
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_anio INTEGER;
    v_mes INTEGER;
    v_fecha_desde DATE;
    v_fecha_hasta DATE;
    v_fecha_ant_desde DATE;
    v_fecha_ant_hasta DATE;
BEGIN
    -- Validar parametros
    v_anio := COALESCE(p_anio, EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER);
    v_mes := COALESCE(p_mes, EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER);

    -- Validar mes en rango valido
    IF v_mes < 1 OR v_mes > 12 THEN
        v_mes := EXTRACT(MONTH FROM CURRENT_DATE)::INTEGER;
    END IF;

    -- Calcular rango de fechas del mes actual
    v_fecha_desde := make_date(v_anio, v_mes, 1);
    v_fecha_hasta := (v_fecha_desde + INTERVAL '1 month' - INTERVAL '1 day')::DATE;

    -- Calcular rango de fechas del mes anterior
    v_fecha_ant_desde := (v_fecha_desde - INTERVAL '1 month')::DATE;
    v_fecha_ant_hasta := (v_fecha_desde - INTERVAL '1 day')::DATE;

    RETURN QUERY
    WITH licencias_mes_actual AS (
        SELECT
            l.id_giro,
            l.zona,
            COUNT(*) AS cnt
        FROM
            comun.licencias l
        WHERE
            l.fecha_alta >= v_fecha_desde
            AND l.fecha_alta <= v_fecha_hasta
        GROUP BY
            l.id_giro, l.zona
    ),
    licencias_mes_anterior AS (
        SELECT
            l.id_giro,
            COUNT(*) AS cnt
        FROM
            comun.licencias l
        WHERE
            l.fecha_alta >= v_fecha_ant_desde
            AND l.fecha_alta <= v_fecha_ant_hasta
        GROUP BY
            l.id_giro
    ),
    resumen_actual AS (
        SELECT
            g.id_giro,
            g.descripcion,
            COALESCE(SUM(CASE WHEN lma.zona = 1 THEN lma.cnt ELSE 0 END), 0)::INTEGER AS z_1,
            COALESCE(SUM(CASE WHEN lma.zona = 2 THEN lma.cnt ELSE 0 END), 0)::INTEGER AS z_2,
            COALESCE(SUM(CASE WHEN lma.zona = 3 THEN lma.cnt ELSE 0 END), 0)::INTEGER AS z_3,
            COALESCE(SUM(CASE WHEN lma.zona = 4 THEN lma.cnt ELSE 0 END), 0)::INTEGER AS z_4,
            COALESCE(SUM(CASE WHEN lma.zona = 5 THEN lma.cnt ELSE 0 END), 0)::INTEGER AS z_5,
            COALESCE(SUM(CASE WHEN lma.zona = 6 THEN lma.cnt ELSE 0 END), 0)::INTEGER AS z_6,
            COALESCE(SUM(CASE WHEN lma.zona = 7 THEN lma.cnt ELSE 0 END), 0)::INTEGER AS z_7,
            COALESCE(SUM(CASE WHEN lma.zona NOT IN (1, 2, 3, 4, 5, 6, 7) OR lma.zona IS NULL THEN lma.cnt ELSE 0 END), 0)::INTEGER AS otros,
            COALESCE(SUM(lma.cnt), 0)::INTEGER AS total
        FROM
            comun.c_giros g
        LEFT JOIN
            licencias_mes_actual lma ON g.id_giro = lma.id_giro
        GROUP BY
            g.id_giro, g.descripcion
    )
    SELECT
        ra.id_giro,
        ra.descripcion::VARCHAR,
        ra.z_1,
        ra.z_2,
        ra.z_3,
        ra.z_4,
        ra.z_5,
        ra.z_6,
        ra.z_7,
        ra.otros,
        ra.total,
        COALESCE(lant.cnt, 0)::INTEGER AS total_mes_anterior,
        CASE
            WHEN COALESCE(lant.cnt, 0) = 0 THEN
                CASE WHEN ra.total > 0 THEN 100.00 ELSE 0.00 END
            ELSE
                ROUND(((ra.total - COALESCE(lant.cnt, 0))::NUMERIC / lant.cnt::NUMERIC) * 100, 2)
        END AS variacion_porcentaje
    FROM
        resumen_actual ra
    LEFT JOIN
        licencias_mes_anterior lant ON ra.id_giro = lant.id_giro
    WHERE
        ra.total > 0 OR COALESCE(lant.cnt, 0) > 0
    ORDER BY
        ra.total DESC, ra.descripcion;
END;
$$;

COMMENT ON FUNCTION comun.sp_rep_estadisticos_lic_mensual(INTEGER, INTEGER) IS
'Reporte mensual de licencias con comparativa porcentual respecto al mes anterior';


-- ====================================================================================
-- SP 4: sp_rep_estadisticos_lic_por_giro
-- DESCRIPCION: Detalle de licencias por giro especifico
-- ====================================================================================
DROP FUNCTION IF EXISTS comun.sp_rep_estadisticos_lic_por_giro(INTEGER, DATE, DATE);

CREATE OR REPLACE FUNCTION comun.sp_rep_estadisticos_lic_por_giro(
    p_id_giro INTEGER,
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE(
    id_licencia INTEGER,
    numero_licencia VARCHAR,
    zona INTEGER,
    fecha_alta DATE,
    propietario VARCHAR,
    domicilio VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_fecha_desde DATE;
    v_fecha_hasta DATE;
BEGIN
    -- Validar parametros de fecha
    v_fecha_desde := COALESCE(p_fecha_desde, CURRENT_DATE - INTERVAL '1 year');
    v_fecha_hasta := COALESCE(p_fecha_hasta, CURRENT_DATE);

    -- Asegurar orden correcto de fechas
    IF v_fecha_desde > v_fecha_hasta THEN
        v_fecha_desde := p_fecha_hasta;
        v_fecha_hasta := p_fecha_desde;
    END IF;

    -- Validar que se proporcione id_giro
    IF p_id_giro IS NULL THEN
        RAISE EXCEPTION 'El parametro p_id_giro es requerido';
    END IF;

    RETURN QUERY
    SELECT
        l.id_licencia,
        COALESCE(l.numero_licencia, '')::VARCHAR AS numero_licencia,
        COALESCE(l.zona, 0)::INTEGER AS zona,
        l.fecha_alta,
        COALESCE(l.propietario, 'Sin propietario')::VARCHAR AS propietario,
        COALESCE(l.domicilio, 'Sin domicilio')::VARCHAR AS domicilio
    FROM
        comun.licencias l
    WHERE
        l.id_giro = p_id_giro
        AND l.fecha_alta >= v_fecha_desde
        AND l.fecha_alta <= v_fecha_hasta
    ORDER BY
        l.fecha_alta DESC, l.numero_licencia;
END;
$$;

COMMENT ON FUNCTION comun.sp_rep_estadisticos_lic_por_giro(INTEGER, DATE, DATE) IS
'Lista detallada de licencias para un giro especifico en un rango de fechas';


-- ====================================================================================
-- SP 5: sp_rep_estadisticos_lic_resumen
-- DESCRIPCION: Resumen ejecutivo con estadisticas consolidadas
-- ====================================================================================
DROP FUNCTION IF EXISTS comun.sp_rep_estadisticos_lic_resumen(DATE, DATE);

CREATE OR REPLACE FUNCTION comun.sp_rep_estadisticos_lic_resumen(
    p_fecha_desde DATE,
    p_fecha_hasta DATE
)
RETURNS TABLE(
    total_licencias BIGINT,
    licencias_nuevas BIGINT,
    licencias_bajas BIGINT,
    licencias_vigentes BIGINT,
    total_por_zona JSONB,
    top_giros JSONB
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_fecha_desde DATE;
    v_fecha_hasta DATE;
    v_total_licencias BIGINT;
    v_licencias_nuevas BIGINT;
    v_licencias_bajas BIGINT;
    v_licencias_vigentes BIGINT;
    v_total_por_zona JSONB;
    v_top_giros JSONB;
BEGIN
    -- Validar y ajustar fechas
    v_fecha_desde := COALESCE(p_fecha_desde, CURRENT_DATE - INTERVAL '1 year');
    v_fecha_hasta := COALESCE(p_fecha_hasta, CURRENT_DATE);

    -- Asegurar orden correcto de fechas
    IF v_fecha_desde > v_fecha_hasta THEN
        v_fecha_desde := p_fecha_hasta;
        v_fecha_hasta := p_fecha_desde;
    END IF;

    -- Calcular total de licencias en el sistema
    SELECT COUNT(*) INTO v_total_licencias
    FROM comun.licencias;

    -- Calcular licencias nuevas en el periodo
    SELECT COUNT(*) INTO v_licencias_nuevas
    FROM comun.licencias l
    WHERE l.fecha_alta >= v_fecha_desde
      AND l.fecha_alta <= v_fecha_hasta;

    -- Calcular licencias dadas de baja en el periodo
    -- Asumiendo que existe campo fecha_baja o vigente = false
    SELECT COUNT(*) INTO v_licencias_bajas
    FROM comun.licencias l
    WHERE COALESCE(l.vigente, true) = false
      AND l.fecha_alta >= v_fecha_desde
      AND l.fecha_alta <= v_fecha_hasta;

    -- Calcular licencias vigentes actuales
    SELECT COUNT(*) INTO v_licencias_vigentes
    FROM comun.licencias l
    WHERE COALESCE(l.vigente, true) = true;

    -- Calcular totales por zona
    SELECT jsonb_build_object(
        'zona_1', COALESCE(SUM(CASE WHEN zona = 1 THEN 1 ELSE 0 END), 0),
        'zona_2', COALESCE(SUM(CASE WHEN zona = 2 THEN 1 ELSE 0 END), 0),
        'zona_3', COALESCE(SUM(CASE WHEN zona = 3 THEN 1 ELSE 0 END), 0),
        'zona_4', COALESCE(SUM(CASE WHEN zona = 4 THEN 1 ELSE 0 END), 0),
        'zona_5', COALESCE(SUM(CASE WHEN zona = 5 THEN 1 ELSE 0 END), 0),
        'zona_6', COALESCE(SUM(CASE WHEN zona = 6 THEN 1 ELSE 0 END), 0),
        'zona_7', COALESCE(SUM(CASE WHEN zona = 7 THEN 1 ELSE 0 END), 0),
        'otros', COALESCE(SUM(CASE WHEN zona NOT IN (1, 2, 3, 4, 5, 6, 7) OR zona IS NULL THEN 1 ELSE 0 END), 0)
    ) INTO v_total_por_zona
    FROM comun.licencias l
    WHERE l.fecha_alta >= v_fecha_desde
      AND l.fecha_alta <= v_fecha_hasta;

    -- Calcular top 10 giros con mas licencias
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'id_giro', giro_data.id_giro,
                'descripcion', giro_data.descripcion,
                'cantidad', giro_data.cantidad,
                'porcentaje', giro_data.porcentaje
            )
        ),
        '[]'::jsonb
    ) INTO v_top_giros
    FROM (
        SELECT
            g.id_giro,
            g.descripcion,
            COUNT(l.id_licencia) AS cantidad,
            ROUND(
                (COUNT(l.id_licencia)::NUMERIC / NULLIF(v_licencias_nuevas, 0)::NUMERIC) * 100,
                2
            ) AS porcentaje
        FROM
            comun.c_giros g
        INNER JOIN
            comun.licencias l ON g.id_giro = l.id_giro
        WHERE
            l.fecha_alta >= v_fecha_desde
            AND l.fecha_alta <= v_fecha_hasta
        GROUP BY
            g.id_giro, g.descripcion
        ORDER BY
            cantidad DESC
        LIMIT 10
    ) giro_data;

    -- Retornar resultados
    RETURN QUERY
    SELECT
        COALESCE(v_total_licencias, 0),
        COALESCE(v_licencias_nuevas, 0),
        COALESCE(v_licencias_bajas, 0),
        COALESCE(v_licencias_vigentes, 0),
        COALESCE(v_total_por_zona, '{}'::jsonb),
        COALESCE(v_top_giros, '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION comun.sp_rep_estadisticos_lic_resumen(DATE, DATE) IS
'Resumen ejecutivo de estadisticas de licencias con totales, distribucion por zona y top giros en formato JSONB';


-- ====================================================================================
-- VERIFICACIONES Y PERMISOS
-- ====================================================================================

-- Verificar que los SPs fueron creados correctamente
DO $$
DECLARE
    v_sp_count INTEGER;
    v_expected_count INTEGER := 5;
BEGIN
    SELECT COUNT(*) INTO v_sp_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'comun'
      AND p.proname IN (
          'sp_rep_estadisticos_lic_rango',
          'sp_rep_estadisticos_lic_anual',
          'sp_rep_estadisticos_lic_mensual',
          'sp_rep_estadisticos_lic_por_giro',
          'sp_rep_estadisticos_lic_resumen'
      );

    IF v_sp_count = v_expected_count THEN
        RAISE NOTICE '=== VERIFICACION EXITOSA ===';
        RAISE NOTICE 'Todos los % SPs del componente REPESTADISTICOSLICFRM fueron creados correctamente', v_expected_count;
    ELSE
        RAISE WARNING '=== VERIFICACION CON DIFERENCIAS ===';
        RAISE WARNING 'Se esperaban % SPs, se encontraron %', v_expected_count, v_sp_count;
    END IF;
END;
$$;

-- Listar los SPs creados con sus firmas
SELECT
    'comun.' || p.proname AS stored_procedure,
    pg_get_function_arguments(p.oid) AS parametros,
    pg_get_function_result(p.oid) AS retorno
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'comun'
  AND p.proname LIKE 'sp_rep_estadisticos_lic%'
ORDER BY p.proname;


-- ====================================================================================
-- RESUMEN DE IMPLEMENTACION
-- ====================================================================================
/*
COMPONENTE: REPESTADISTICOSLICFRM
MODULO: padron_licencias
SCHEMA: comun

STORED PROCEDURES IMPLEMENTADOS:

1. comun.sp_rep_estadisticos_lic_rango(p_fecha_desde DATE, p_fecha_hasta DATE)
   - Reporte por rango de fechas
   - Agrupa licencias por giro y zona (1-7 + otros)
   - Retorna: id_giro, descripcion, z_1..z_7, otros, total

2. comun.sp_rep_estadisticos_lic_anual(p_anio INTEGER)
   - Reporte anual completo
   - Si p_anio es NULL usa anio actual
   - Mismo formato de retorno que rango

3. comun.sp_rep_estadisticos_lic_mensual(p_anio INTEGER, p_mes INTEGER)
   - Reporte mensual con comparativa
   - Incluye variacion_porcentaje respecto al mes anterior
   - Retorna: columnas de zona + total_mes_anterior + variacion_porcentaje

4. comun.sp_rep_estadisticos_lic_por_giro(p_id_giro INTEGER, p_fecha_desde DATE, p_fecha_hasta DATE)
   - Detalle de licencias por giro especifico
   - Retorna: id_licencia, numero_licencia, zona, fecha_alta, propietario, domicilio

5. comun.sp_rep_estadisticos_lic_resumen(p_fecha_desde DATE, p_fecha_hasta DATE)
   - Resumen ejecutivo consolidado
   - Usa JSONB para estructuras complejas
   - Retorna: total_licencias, licencias_nuevas, licencias_bajas, licencias_vigentes,
              total_por_zona (JSONB), top_giros (JSONB con top 10)

TABLAS REFERENCIADAS:
- comun.licencias (id_licencia, numero_licencia, id_giro, zona, fecha_alta, vigente, propietario, domicilio)
- comun.c_giros (id_giro, descripcion)

CARACTERISTICAS:
- Todos los SPs usan LANGUAGE plpgsql
- Prefijos: p_ para parametros, v_ para variables
- Manejo de NULL con COALESCE
- Pivoteo de zonas con COUNT(CASE WHEN...)
- Validacion de rangos de fechas
- SECURITY DEFINER para control de acceso
- Comentarios en cada funcion
*/
