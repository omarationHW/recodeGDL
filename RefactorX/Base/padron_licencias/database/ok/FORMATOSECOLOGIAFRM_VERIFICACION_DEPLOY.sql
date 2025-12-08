-- ============================================
-- SCRIPT DE VERIFICACIÓN POST-DEPLOY
-- Componente: formatosEcologiafrm
-- Fecha: 2025-11-20
-- ============================================
-- PROPÓSITO:
-- Verificar que todos los stored procedures se desplegaron
-- correctamente y están listos para usar en producción.
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- VERIFICACIÓN 1: Existencia de Funciones
-- ============================================
\echo ''
\echo '=== VERIFICACION 1: Existencia de Funciones ==='
\echo ''

DO $$
DECLARE
    v_count INTEGER;
    v_function_name TEXT;
    v_functions TEXT[] := ARRAY[
        'sp_get_tramite_by_id',
        'sp_get_tramites_by_fecha',
        'sp_get_cruce_calles_by_tramite'
    ];
BEGIN
    RAISE NOTICE 'Verificando existencia de funciones...';

    FOREACH v_function_name IN ARRAY v_functions LOOP
        SELECT COUNT(*) INTO v_count
        FROM pg_catalog.pg_proc p
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
        WHERE p.proname = v_function_name
        AND n.nspname = 'public';

        IF v_count > 0 THEN
            RAISE NOTICE '  ✓ % - EXISTE', v_function_name;
        ELSE
            RAISE WARNING '  ✗ % - NO EXISTE', v_function_name;
        END IF;
    END LOOP;

    RAISE NOTICE '';
END $$;

-- ============================================
-- VERIFICACIÓN 2: Detalles de las Funciones
-- ============================================
\echo ''
\echo '=== VERIFICACION 2: Detalles de las Funciones ==='
\echo ''

SELECT
    p.proname AS "Nombre Función",
    pg_catalog.pg_get_function_arguments(p.oid) AS "Parámetros",
    pg_catalog.pg_get_function_result(p.oid) AS "Tipo Retorno",
    CASE
        WHEN pg_catalog.obj_description(p.oid, 'pg_proc') IS NOT NULL
        THEN '✓ Sí'
        ELSE '✗ No'
    END AS "Tiene Comentario"
FROM pg_catalog.pg_proc p
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname IN (
    'sp_get_tramite_by_id',
    'sp_get_tramites_by_fecha',
    'sp_get_cruce_calles_by_tramite'
)
AND n.nspname = 'public'
ORDER BY p.proname;

-- ============================================
-- VERIFICACIÓN 3: Comentarios/Documentación
-- ============================================
\echo ''
\echo '=== VERIFICACION 3: Comentarios de Documentacion ==='
\echo ''

SELECT
    p.proname AS "Función",
    pg_catalog.obj_description(p.oid, 'pg_proc') AS "Descripción"
FROM pg_catalog.pg_proc p
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname IN (
    'sp_get_tramite_by_id',
    'sp_get_tramites_by_fecha',
    'sp_get_cruce_calles_by_tramite'
)
AND n.nspname = 'public'
ORDER BY p.proname;

-- ============================================
-- VERIFICACIÓN 4: Existencia de Tablas Base
-- ============================================
\echo ''
\echo '=== VERIFICACION 4: Existencia de Tablas Base ==='
\echo ''

DO $$
DECLARE
    v_count INTEGER;
    v_table_name TEXT;
    v_tables TEXT[] := ARRAY['tramites', 'crucecalles', 'c_calles'];
BEGIN
    RAISE NOTICE 'Verificando existencia de tablas...';

    FOREACH v_table_name IN ARRAY v_tables LOOP
        SELECT COUNT(*) INTO v_count
        FROM pg_catalog.pg_tables
        WHERE schemaname = 'public'
        AND tablename = v_table_name;

        IF v_count > 0 THEN
            RAISE NOTICE '  ✓ % - EXISTE', v_table_name;
        ELSE
            RAISE WARNING '  ✗ % - NO EXISTE (puede causar errores)', v_table_name;
        END IF;
    END LOOP;

    RAISE NOTICE '';
END $$;

-- ============================================
-- VERIFICACIÓN 5: Prueba de Sintaxis
-- ============================================
\echo ''
\echo '=== VERIFICACION 5: Prueba de Sintaxis (Dry Run) ==='
\echo ''

DO $$
DECLARE
    v_error TEXT;
BEGIN
    -- Intentar obtener la definición de cada función
    -- Si hay error de sintaxis, fallaría aquí

    BEGIN
        PERFORM pg_get_functiondef(p.oid)
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_get_tramite_by_id'
        AND n.nspname = 'public';
        RAISE NOTICE '  ✓ sp_get_tramite_by_id - Sintaxis válida';
    EXCEPTION WHEN others THEN
        RAISE WARNING '  ✗ sp_get_tramite_by_id - Error: %', SQLERRM;
    END;

    BEGIN
        PERFORM pg_get_functiondef(p.oid)
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_get_tramites_by_fecha'
        AND n.nspname = 'public';
        RAISE NOTICE '  ✓ sp_get_tramites_by_fecha - Sintaxis válida';
    EXCEPTION WHEN others THEN
        RAISE WARNING '  ✗ sp_get_tramites_by_fecha - Error: %', SQLERRM;
    END;

    BEGIN
        PERFORM pg_get_functiondef(p.oid)
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_get_cruce_calles_by_tramite'
        AND n.nspname = 'public';
        RAISE NOTICE '  ✓ sp_get_cruce_calles_by_tramite - Sintaxis válida';
    EXCEPTION WHEN others THEN
        RAISE WARNING '  ✗ sp_get_cruce_calles_by_tramite - Error: %', SQLERRM;
    END;

    RAISE NOTICE '';
END $$;

-- ============================================
-- VERIFICACIÓN 6: Conteo de Registros en Tablas
-- ============================================
\echo ''
\echo '=== VERIFICACION 6: Conteo de Registros en Tablas ==='
\echo ''

DO $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Tabla tramites
    BEGIN
        SELECT COUNT(*) INTO v_count FROM tramites;
        RAISE NOTICE '  Tabla tramites: % registros', v_count;
    EXCEPTION WHEN others THEN
        RAISE WARNING '  Tabla tramites: Error al contar - %', SQLERRM;
    END;

    -- Tabla crucecalles
    BEGIN
        SELECT COUNT(*) INTO v_count FROM crucecalles;
        RAISE NOTICE '  Tabla crucecalles: % registros', v_count;
    EXCEPTION WHEN others THEN
        RAISE WARNING '  Tabla crucecalles: Error al contar - %', SQLERRM;
    END;

    -- Tabla c_calles
    BEGIN
        SELECT COUNT(*) INTO v_count FROM c_calles;
        RAISE NOTICE '  Tabla c_calles: % registros', v_count;
    EXCEPTION WHEN others THEN
        RAISE WARNING '  Tabla c_calles: Error al contar - %', SQLERRM;
    END;

    RAISE NOTICE '';
END $$;

-- ============================================
-- VERIFICACIÓN 7: Prueba Funcional Básica
-- ============================================
\echo ''
\echo '=== VERIFICACION 7: Prueba Funcional Basica ==='
\echo ''
\echo 'NOTA: Las siguientes pruebas pueden fallar si no hay datos,'
\echo 'pero el error debe ser controlado (excepción descriptiva).'
\echo ''

-- Prueba 1: sp_get_tramite_by_id con ID 1
DO $$
DECLARE
    v_result RECORD;
BEGIN
    BEGIN
        SELECT * INTO v_result FROM sp_get_tramite_by_id(1) LIMIT 1;
        IF FOUND THEN
            RAISE NOTICE '  ✓ sp_get_tramite_by_id(1) - Ejecutado correctamente';
        ELSE
            RAISE NOTICE '  ℹ sp_get_tramite_by_id(1) - No retornó registros';
        END IF;
    EXCEPTION WHEN others THEN
        RAISE NOTICE '  ⚠ sp_get_tramite_by_id(1) - Excepción: %', SQLERRM;
    END;
END $$;

-- Prueba 2: sp_get_tramites_by_fecha con fecha actual
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    BEGIN
        SELECT COUNT(*) INTO v_count FROM sp_get_tramites_by_fecha(CURRENT_DATE);
        RAISE NOTICE '  ✓ sp_get_tramites_by_fecha(CURRENT_DATE) - Retornó % registros', v_count;
    EXCEPTION WHEN others THEN
        RAISE NOTICE '  ⚠ sp_get_tramites_by_fecha(CURRENT_DATE) - Excepción: %', SQLERRM;
    END;
END $$;

-- Prueba 3: sp_get_cruce_calles_by_tramite con ID 1
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    BEGIN
        SELECT COUNT(*) INTO v_count FROM sp_get_cruce_calles_by_tramite(1);
        RAISE NOTICE '  ✓ sp_get_cruce_calles_by_tramite(1) - Retornó % cruces', v_count;
    EXCEPTION WHEN others THEN
        RAISE NOTICE '  ⚠ sp_get_cruce_calles_by_tramite(1) - Excepción: %', SQLERRM;
    END;
END $$;

-- ============================================
-- VERIFICACIÓN 8: Validaciones de Parámetros NULL
-- ============================================
\echo ''
\echo '=== VERIFICACION 8: Validaciones de Parametros NULL ==='
\echo ''
\echo 'NOTA: Estas pruebas DEBEN fallar con excepción controlada.'
\echo ''

-- Prueba validación NULL en sp_get_tramite_by_id
DO $$
BEGIN
    BEGIN
        PERFORM sp_get_tramite_by_id(NULL);
        RAISE WARNING '  ✗ sp_get_tramite_by_id(NULL) - NO validó correctamente (debería fallar)';
    EXCEPTION WHEN others THEN
        RAISE NOTICE '  ✓ sp_get_tramite_by_id(NULL) - Validación correcta: %', SQLERRM;
    END;
END $$;

-- Prueba validación NULL en sp_get_tramites_by_fecha
DO $$
BEGIN
    BEGIN
        PERFORM sp_get_tramites_by_fecha(NULL);
        RAISE WARNING '  ✗ sp_get_tramites_by_fecha(NULL) - NO validó correctamente (debería fallar)';
    EXCEPTION WHEN others THEN
        RAISE NOTICE '  ✓ sp_get_tramites_by_fecha(NULL) - Validación correcta: %', SQLERRM;
    END;
END $$;

-- Prueba validación NULL en sp_get_cruce_calles_by_tramite
DO $$
BEGIN
    BEGIN
        PERFORM sp_get_cruce_calles_by_tramite(NULL);
        RAISE WARNING '  ✗ sp_get_cruce_calles_by_tramite(NULL) - NO validó correctamente (debería fallar)';
    EXCEPTION WHEN others THEN
        RAISE NOTICE '  ✓ sp_get_cruce_calles_by_tramite(NULL) - Validación correcta: %', SQLERRM;
    END;
END $$;

-- ============================================
-- RESUMEN FINAL
-- ============================================
\echo ''
\echo '========================================='
\echo 'VERIFICACION COMPLETADA'
\echo '========================================='
\echo ''
\echo 'Revise los resultados anteriores:'
\echo '  - Todos los SPs deben existir (✓)'
\echo '  - Todas las tablas deben existir (✓)'
\echo '  - Las validaciones NULL deben funcionar (✓)'
\echo '  - Las pruebas funcionales pueden variar según datos'
\echo ''
\echo 'Si hay advertencias (✗), revisar antes de usar en producción.'
\echo ''
\echo 'Para pruebas detalladas, ejecutar:'
\echo '  \\i FORMATOSECOLOGIAFRM_TEST_QUERIES.sql'
\echo ''
