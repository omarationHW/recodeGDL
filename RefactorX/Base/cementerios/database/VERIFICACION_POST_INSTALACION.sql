-- ============================================
-- SCRIPT DE VERIFICACIÓN POST-INSTALACIÓN
-- STORED PROCEDURES - MÓDULO CEMENTERIOS
-- ============================================
-- Base de Datos: padron_licencias
-- Total SPs Esperados: 93
-- Fecha: 2025-11-09
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- SECCIÓN 1: CONTEO GENERAL DE SPs
-- ============================================

\echo '============================================'
\echo 'VERIFICACIÓN POST-INSTALACIÓN - CEMENTERIOS'
\echo '============================================'
\echo ''

\echo '1. CONTEO GENERAL DE STORED PROCEDURES'
\echo '--------------------------------------'

-- Total de SPs en el esquema public
SELECT
    '1.1 Total SPs en esquema public:' as descripcion,
    COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public';

-- Total de SPs relacionados con cementerios
SELECT
    '1.2 Total SPs de cementerios:' as descripcion,
    COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_name LIKE 'sp_%'
    OR routine_name LIKE 'SP_CEMENTERIOS_%');

-- ============================================
-- SECCIÓN 2: SPs POR CATEGORÍA
-- ============================================

\echo ''
\echo '2. STORED PROCEDURES POR CATEGORÍA'
\echo '--------------------------------------'

-- SPs CORE (SP_CEMENTERIOS_*)
SELECT
    '2.1 SPs CORE (SP_CEMENTERIOS_*):' as categoria,
    COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'SP_CEMENTERIOS_%';

-- SPs del módulo 13 (sp_13_*)
SELECT
    '2.2 SPs Módulo 13 (sp_13_*):' as categoria,
    COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE 'sp_13_%';

-- SPs de bonificaciones
SELECT
    '2.3 SPs Bonificaciones:' as categoria,
    COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%bonificacion%';

-- SPs de recargos
SELECT
    '2.4 SPs Recargos:' as categoria,
    COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%recargo%';

-- SPs de estadísticas
SELECT
    '2.5 SPs Estadísticas:' as categoria,
    COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%estad%';

-- SPs de consultas
SELECT
    '2.6 SPs Consultas:' as categoria,
    COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%consulta%';

-- SPs de reportes
SELECT
    '2.7 SPs Reportes:' as categoria,
    COUNT(*) as total
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%rep_%';

-- ============================================
-- SECCIÓN 3: LISTA COMPLETA DE SPs DE CEMENTERIOS
-- ============================================

\echo ''
\echo '3. LISTA COMPLETA DE SPs DE CEMENTERIOS'
\echo '--------------------------------------'

SELECT
    routine_name as nombre_sp,
    routine_type as tipo,
    CASE
        WHEN data_type = 'record' THEN 'TABLE'
        WHEN data_type = 'void' THEN 'PROCEDURE'
        ELSE data_type
    END as retorno
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_name LIKE 'sp_%'
    OR routine_name LIKE 'SP_CEMENTERIOS_%')
ORDER BY routine_name;

-- ============================================
-- SECCIÓN 4: SPs CRÍTICOS (VERIFICAR EXISTENCIA)
-- ============================================

\echo ''
\echo '4. VERIFICACIÓN DE SPs CRÍTICOS'
\echo '--------------------------------------'

-- Verificar SPs CORE críticos
SELECT
    sp_name,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines
            WHERE routine_schema = 'public' AND routine_name = sp_name
        ) THEN '✓ EXISTE'
        ELSE '✗ FALTA'
    END as estado
FROM (VALUES
    ('SP_CEMENTERIOS_DIFUNTOS_LIST'),
    ('SP_CEMENTERIOS_DIFUNTO_GET'),
    ('SP_CEMENTERIOS_DIFUNTO_CREATE'),
    ('SP_CEMENTERIOS_CEMENTERIOS_LIST'),
    ('SP_CEMENTERIOS_LOTES_LIST'),
    ('SP_CEMENTERIOS_SERVICIOS_LIST'),
    ('SP_CEMENTERIOS_PAGOS_LIST'),
    ('SP_CEMENTERIOS_BUSCAR_DIFUNTO'),
    ('SP_CEMENTERIOS_ESTADISTICAS')
) AS sps(sp_name);

-- Verificar SPs GESTIÓN críticos
SELECT
    sp_name,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines
            WHERE routine_schema = 'public' AND routine_name = sp_name
        ) THEN '✓ EXISTE'
        ELSE '✗ FALTA'
    END as estado
FROM (VALUES
    ('SP_CEMENTERIOS_SERVICIO_CREATE'),
    ('SP_CEMENTERIOS_PAGO_CREATE'),
    ('SP_CEMENTERIOS_LOTE_LIBERAR'),
    ('SP_CEMENTERIOS_RENOVACION_CREATE'),
    ('SP_CEMENTERIOS_RENOVACION_CONFIRMAR'),
    ('SP_CEMENTERIOS_REPORTES_OCUPACION'),
    ('SP_CEMENTERIOS_VENCIMIENTOS_PROXIMOS'),
    ('SP_CEMENTERIOS_DASHBOARD_RESUMEN')
) AS sps(sp_name);

-- Verificar SPs ABC críticos
SELECT
    sp_name,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines
            WHERE routine_schema = 'public' AND routine_name = sp_name
        ) THEN '✓ EXISTE'
        ELSE '✗ FALTA'
    END as estado
FROM (VALUES
    ('SP_CEMENTERIOS_FOLIO_GET'),
    ('SP_CEMENTERIOS_FOLIO_HISTORIA'),
    ('SP_CEMENTERIOS_FOLIO_BAJA'),
    ('SP_CEMENTERIOS_ADICIONALES_GET'),
    ('SP_CEMENTERIOS_REPORTES_MENSUAL')
) AS sps(sp_name);

-- Verificar SPs EXACTO críticos
SELECT
    sp_name,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.routines
            WHERE routine_schema = 'public' AND routine_name = sp_name
        ) THEN '✓ EXISTE'
        ELSE '✗ FALTA'
    END as estado
FROM (VALUES
    ('sp_13_historia'),
    ('spd_abc_adercm'),
    ('sp_bonificaciones_create'),
    ('sp_bonificaciones_update'),
    ('sp_bonificaciones_delete'),
    ('sp_estad_adeudo_resumen'),
    ('sp_estad_adeudo_listado'),
    ('sp_acceso_login')
) AS sps(sp_name);

-- ============================================
-- SECCIÓN 5: VERIFICACIÓN DE TABLAS NECESARIAS
-- ============================================

\echo ''
\echo '5. VERIFICACIÓN DE TABLAS NECESARIAS'
\echo '--------------------------------------'

-- Tablas del módulo 13
SELECT
    table_name as tabla,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as columnas,
    '✓ EXISTE' as estado
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND (table_name LIKE 'ta_13_%' OR table_name LIKE 'tc_13_%')
ORDER BY table_name;

-- Tablas CORE de cementerios (si existen)
SELECT
    table_name as tabla,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as columnas,
    '✓ EXISTE' as estado
FROM information_schema.tables t
WHERE table_schema = 'public'
  AND table_name IN (
    'difuntos',
    'cementerios',
    'lotes',
    'servicios',
    'pagos',
    'renovaciones',
    'historial_exhumaciones',
    'historial_folios',
    'servicios_adicionales',
    'folios'
  )
ORDER BY table_name;

-- ============================================
-- SECCIÓN 6: CONTEO DE DATOS EN TABLAS
-- ============================================

\echo ''
\echo '6. CONTEO DE DATOS EN TABLAS PRINCIPALES'
\echo '--------------------------------------'

-- Contar registros en tablas principales (si existen)
DO $$
DECLARE
    tabla_name text;
    tabla_count integer;
BEGIN
    RAISE NOTICE '6. CONTEO DE DATOS EN TABLAS PRINCIPALES';
    RAISE NOTICE '--------------------------------------';

    FOR tabla_name IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND (table_name LIKE 'ta_13_%' OR table_name LIKE 'tc_13_%')
        ORDER BY table_name
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', tabla_name) INTO tabla_count;
        RAISE NOTICE '  % : % registros', tabla_name, tabla_count;
    END LOOP;
END $$;

-- ============================================
-- SECCIÓN 7: PRUEBAS DE EJECUCIÓN DE SPs
-- ============================================

\echo ''
\echo '7. PRUEBAS DE EJECUCIÓN DE SPs CRÍTICOS'
\echo '--------------------------------------'

\echo '7.1 Test: SP_CEMENTERIOS_ESTADISTICAS'
\echo '  Intentando ejecutar...'

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_schema = 'public' AND routine_name = 'SP_CEMENTERIOS_ESTADISTICAS'
    ) THEN
        PERFORM * FROM SP_CEMENTERIOS_ESTADISTICAS();
        RAISE NOTICE '  ✓ SP ejecuta correctamente';
    ELSE
        RAISE NOTICE '  ✗ SP no existe';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '  ⚠ Error al ejecutar: %', SQLERRM;
END $$;

\echo '7.2 Test: sp_estad_adeudo_resumen'
\echo '  Intentando ejecutar...'

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_schema = 'public' AND routine_name = 'sp_estad_adeudo_resumen'
    ) THEN
        PERFORM * FROM sp_estad_adeudo_resumen();
        RAISE NOTICE '  ✓ SP ejecuta correctamente';
    ELSE
        RAISE NOTICE '  ✗ SP no existe';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '  ⚠ Error al ejecutar: %', SQLERRM;
END $$;

\echo '7.3 Test: SP_CEMENTERIOS_CEMENTERIOS_LIST'
\echo '  Intentando ejecutar...'

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_schema = 'public' AND routine_name = 'SP_CEMENTERIOS_CEMENTERIOS_LIST'
    ) THEN
        PERFORM * FROM SP_CEMENTERIOS_CEMENTERIOS_LIST();
        RAISE NOTICE '  ✓ SP ejecuta correctamente';
    ELSE
        RAISE NOTICE '  ✗ SP no existe';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '  ⚠ Error al ejecutar: %', SQLERRM;
END $$;

\echo '7.4 Test: SP_CEMENTERIOS_DASHBOARD_RESUMEN'
\echo '  Intentando ejecutar...'

DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.routines
        WHERE routine_schema = 'public' AND routine_name = 'SP_CEMENTERIOS_DASHBOARD_RESUMEN'
    ) THEN
        PERFORM * FROM SP_CEMENTERIOS_DASHBOARD_RESUMEN();
        RAISE NOTICE '  ✓ SP ejecuta correctamente';
    ELSE
        RAISE NOTICE '  ✗ SP no existe';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '  ⚠ Error al ejecutar: %', SQLERRM;
END $$;

-- ============================================
-- SECCIÓN 8: RESUMEN FINAL
-- ============================================

\echo ''
\echo '8. RESUMEN FINAL'
\echo '============================================'

SELECT
    'Total SPs esperados: 93' as resumen
UNION ALL
SELECT
    'Total SPs instalados: ' || COUNT(*)
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_name LIKE 'sp_%'
    OR routine_name LIKE 'SP_CEMENTERIOS_%')
UNION ALL
SELECT
    CASE
        WHEN COUNT(*) >= 93 THEN '✓ INSTALACIÓN COMPLETA'
        WHEN COUNT(*) >= 70 THEN '⚠ INSTALACIÓN PARCIAL (revisar errores)'
        ELSE '✗ INSTALACIÓN INCOMPLETA (errores críticos)'
    END
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_name LIKE 'sp_%'
    OR routine_name LIKE 'SP_CEMENTERIOS_%');

\echo ''
\echo '============================================'
\echo 'FIN DE VERIFICACIÓN'
\echo '============================================'
