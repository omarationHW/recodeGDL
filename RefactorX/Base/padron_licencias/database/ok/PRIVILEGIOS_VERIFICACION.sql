-- ============================================
-- SCRIPT DE VERIFICACIÓN - PRIVILEGIOS
-- Componente: privilegios
-- Módulo: padron_licencias
-- Fecha: 2025-11-20
-- ============================================

-- ============================================
-- PARTE 1: Verificar creación de funciones
-- ============================================

\echo '============================================'
\echo 'VERIFICACIÓN DE STORED PROCEDURES - PRIVILEGIOS'
\echo '============================================'
\echo ''
\echo 'Verificando existencia de 7 funciones...'
\echo ''

SELECT
    n.nspname AS schema,
    p.proname AS nombre_funcion,
    pg_get_function_arguments(p.oid) AS parametros,
    CASE
        WHEN p.prorettype = 'pg_catalog.record'::pg_catalog.regtype THEN 'RETURNS TABLE'
        ELSE pg_catalog.format_type(p.prorettype, NULL)
    END AS tipo_retorno
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE p.proname IN (
    'sp_get_usuarios_privilegios',
    'sp_get_permisos_usuario',
    'sp_get_auditoria_usuario',
    'sp_get_mov_tramites',
    'sp_get_mov_licencias',
    'sp_get_deptos',
    'sp_get_revisiones'
)
AND n.nspname = 'public'
ORDER BY p.proname;

\echo ''
\echo 'Debe mostrar 7 funciones'
\echo ''

-- ============================================
-- PARTE 2: Verificar tablas requeridas
-- ============================================

\echo '============================================'
\echo 'VERIFICACIÓN DE TABLAS REQUERIDAS'
\echo '============================================'
\echo ''

SELECT
    schemaname AS schema,
    tablename AS tabla,
    'EXISTS' AS status
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN (
    'c_programas',
    'autoriza',
    'aud_auto',
    'usuarios',
    'deptos',
    'c_dependencias',
    'sysbacktram',
    'sysbacklcs',
    'revisiones',
    'seg_revision'
)
ORDER BY tablename;

\echo ''
\echo 'Deben existir 10 tablas'
\echo ''

-- ============================================
-- PARTE 3: Tests básicos de funcionalidad
-- ============================================

\echo '============================================'
\echo 'TESTS BÁSICOS DE FUNCIONALIDAD'
\echo '============================================'
\echo ''

-- Test 1: sp_get_usuarios_privilegios
\echo 'Test 1: sp_get_usuarios_privilegios (primeros 5 usuarios)'
\echo '-----------------------------------------------------------'

SELECT
    usuario,
    nombres,
    nombredepto,
    total_registros
FROM public.sp_get_usuarios_privilegios('usuario', '', 0, 5);

\echo ''

-- Test 2: sp_get_deptos
\echo 'Test 2: sp_get_deptos (catálogo de departamentos)'
\echo '-----------------------------------------------------------'

SELECT
    cvedepto,
    nombredepto
FROM public.sp_get_deptos()
LIMIT 10;

\echo ''

-- ============================================
-- PARTE 4: Validación de parámetros
-- ============================================

\echo '============================================'
\echo 'TESTS DE VALIDACIÓN DE PARÁMETROS'
\echo '============================================'
\echo ''

-- Test 3: Validación offset negativo (debe fallar)
\echo 'Test 3: Validación offset negativo (debe mostrar error)'
\echo '-----------------------------------------------------------'

DO $$
BEGIN
    PERFORM * FROM public.sp_get_usuarios_privilegios('usuario', '', -1, 10);
    RAISE NOTICE 'ERROR: No se validó offset negativo';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'OK: Validación de offset funcionó correctamente - %', SQLERRM;
END $$;

\echo ''

-- Test 4: Validación limit fuera de rango (debe fallar)
\echo 'Test 4: Validación limit > 1000 (debe mostrar error)'
\echo '-----------------------------------------------------------'

DO $$
BEGIN
    PERFORM * FROM public.sp_get_usuarios_privilegios('usuario', '', 0, 2000);
    RAISE NOTICE 'ERROR: No se validó limit > 1000';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'OK: Validación de limit funcionó correctamente - %', SQLERRM;
END $$;

\echo ''

-- Test 5: Validación parámetro vacío (debe fallar)
\echo 'Test 5: Validación p_usuario vacío (debe mostrar error)'
\echo '-----------------------------------------------------------'

DO $$
BEGIN
    PERFORM * FROM public.sp_get_permisos_usuario('');
    RAISE NOTICE 'ERROR: No se validó p_usuario vacío';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'OK: Validación de p_usuario funcionó correctamente - %', SQLERRM;
END $$;

\echo ''

-- Test 6: Validación rango de fechas (debe fallar)
\echo 'Test 6: Validación fecha_ini > fecha_fin (debe mostrar error)'
\echo '-----------------------------------------------------------'

DO $$
BEGIN
    PERFORM * FROM public.sp_get_revisiones('2025-12-31'::DATE, '2025-01-01'::DATE, 'admin');
    RAISE NOTICE 'ERROR: No se validó rango de fechas';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'OK: Validación de rango de fechas funcionó correctamente - %', SQLERRM;
END $$;

\echo ''

-- ============================================
-- PARTE 5: Resumen de verificación
-- ============================================

\echo '============================================'
\echo 'RESUMEN DE VERIFICACIÓN'
\echo '============================================'
\echo ''

WITH
    funciones_esperadas AS (
        SELECT unnest(ARRAY[
            'sp_get_usuarios_privilegios',
            'sp_get_permisos_usuario',
            'sp_get_auditoria_usuario',
            'sp_get_mov_tramites',
            'sp_get_mov_licencias',
            'sp_get_deptos',
            'sp_get_revisiones'
        ]) AS nombre
    ),
    funciones_existentes AS (
        SELECT proname AS nombre
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
    )
SELECT
    CASE
        WHEN COUNT(fe.nombre) = 7 THEN 'EXITOSO'
        ELSE 'FALLIDO'
    END AS resultado_verificacion,
    COUNT(fe.nombre) AS funciones_creadas,
    7 AS funciones_esperadas,
    7 - COUNT(fe.nombre) AS funciones_faltantes
FROM funciones_esperadas fe
LEFT JOIN funciones_existentes fx ON fx.nombre = fe.nombre
WHERE fx.nombre IS NOT NULL;

\echo ''
\echo '============================================'
\echo 'FIN DE VERIFICACIÓN'
\echo '============================================'

-- ============================================
-- PARTE 6: Información adicional
-- ============================================

\echo ''
\echo 'Información adicional:'
\echo '- Total de SPs implementados: 7'
\echo '- Schema utilizado: public'
\echo '- Tablas principales: 10'
\echo '- Patrón: RETURNS TABLE con validaciones'
\echo ''
\echo 'Para tests con datos reales, ejecutar:'
\echo '  SELECT * FROM public.sp_get_usuarios_privilegios(''usuario'', '''', 0, 10);'
\echo '  SELECT * FROM public.sp_get_permisos_usuario(''nombre_usuario'');'
\echo '  SELECT * FROM public.sp_get_auditoria_usuario(''nombre_usuario'');'
\echo '  SELECT * FROM public.sp_get_deptos();'
\echo ''
