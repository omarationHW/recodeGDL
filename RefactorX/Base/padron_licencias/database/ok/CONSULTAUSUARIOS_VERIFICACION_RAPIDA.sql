-- =====================================================
-- VERIFICACIÓN RÁPIDA POST-DEPLOYMENT
-- Componente: consultausuariosfrm
-- Fecha: 2025-11-20
-- =====================================================
-- Este script verifica rápidamente que todos los SPs
-- estén correctamente desplegados y funcionales
-- =====================================================

\echo '================================================='
\echo 'VERIFICACIÓN RÁPIDA - CONSULTAUSUARIOSFRM'
\echo '================================================='
\echo ''

-- =====================================================
-- 1. VERIFICAR EXTENSIÓN PGCRYPTO
-- =====================================================
\echo '1. Verificando extensión pgcrypto...'

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto')
        THEN '   ✓ pgcrypto instalada'
        ELSE '   ✗ ERROR: pgcrypto NO instalada'
    END as status;

-- =====================================================
-- 2. VERIFICAR SCHEMA COMUN
-- =====================================================
\echo '2. Verificando schema comun...'

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'comun')
        THEN '   ✓ Schema comun existe'
        ELSE '   ✗ ERROR: Schema comun NO existe'
    END as status;

-- =====================================================
-- 3. VERIFICAR STORED PROCEDURES
-- =====================================================
\echo '3. Verificando stored procedures (9 esperados)...'

DO $$
DECLARE
    v_count INTEGER;
    v_sps TEXT[] := ARRAY[
        'get_all_usuarios',
        'consulta_usuario_por_usuario',
        'consulta_usuario_por_nombre',
        'consulta_usuario_por_depto',
        'get_dependencias',
        'get_deptos_by_dependencia',
        'crear_usuario',
        'actualizar_usuario',
        'dar_baja_usuario'
    ];
    v_sp TEXT;
    v_found INTEGER := 0;
    v_missing TEXT[] := ARRAY[]::TEXT[];
BEGIN
    FOREACH v_sp IN ARRAY v_sps
    LOOP
        SELECT COUNT(*) INTO v_count
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
          AND p.proname = v_sp;

        IF v_count > 0 THEN
            v_found := v_found + 1;
            RAISE NOTICE '   ✓ comun.%', v_sp;
        ELSE
            RAISE NOTICE '   ✗ comun.% - FALTANTE', v_sp;
            v_missing := array_append(v_missing, v_sp);
        END IF;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '   Total encontrados: % / 9', v_found;

    IF array_length(v_missing, 1) IS NULL THEN
        RAISE NOTICE '   ✓ TODOS LOS SPs ESTÁN DESPLEGADOS';
    ELSE
        RAISE NOTICE '   ✗ FALTAN % SPs: %', array_length(v_missing, 1), array_to_string(v_missing, ', ');
    END IF;
END $$;

-- =====================================================
-- 4. VERIFICAR TABLAS REQUERIDAS
-- =====================================================
\echo ''
\echo '4. Verificando tablas requeridas...'

SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables
            WHERE table_schema = 'comun' AND table_name = 'usuarios'
        )
        THEN '   ✓ comun.usuarios existe'
        ELSE '   ✗ ADVERTENCIA: comun.usuarios NO existe'
    END as status_usuarios;

SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables
            WHERE table_schema = 'comun' AND table_name = 'deptos'
        )
        THEN '   ✓ comun.deptos existe'
        ELSE '   ✗ ADVERTENCIA: comun.deptos NO existe'
    END as status_deptos;

SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables
            WHERE table_schema = 'comun' AND table_name = 'c_dependencias'
        )
        THEN '   ✓ comun.c_dependencias existe'
        ELSE '   ✗ ADVERTENCIA: comun.c_dependencias NO existe'
    END as status_dependencias;

-- =====================================================
-- 5. PRUEBA FUNCIONAL BÁSICA - CATÁLOGOS
-- =====================================================
\echo ''
\echo '5. Probando funcionalidad básica (catálogos)...'

-- Probar get_dependencias
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM comun.get_dependencias();
    RAISE NOTICE '   ✓ get_dependencias() ejecutado: % registros', v_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '   ✗ ERROR en get_dependencias(): %', SQLERRM;
END $$;

-- Probar get_deptos_by_dependencia
DO $$
DECLARE
    v_count INTEGER;
    v_id_dep INTEGER;
BEGIN
    SELECT id_dependencia INTO v_id_dep
    FROM comun.c_dependencias
    LIMIT 1;

    IF v_id_dep IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count
        FROM comun.get_deptos_by_dependencia(v_id_dep);
        RAISE NOTICE '   ✓ get_deptos_by_dependencia(%) ejecutado: % registros', v_id_dep, v_count;
    ELSE
        RAISE NOTICE '   - get_deptos_by_dependencia() omitido (no hay dependencias)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '   ✗ ERROR en get_deptos_by_dependencia(): %', SQLERRM;
END $$;

-- =====================================================
-- 6. PRUEBA FUNCIONAL BÁSICA - CONSULTAS
-- =====================================================
\echo ''
\echo '6. Probando funcionalidad básica (consultas)...'

-- Probar get_all_usuarios
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM comun.get_all_usuarios();
    RAISE NOTICE '   ✓ get_all_usuarios() ejecutado: % registros', v_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '   ✗ ERROR en get_all_usuarios(): %', SQLERRM;
END $$;

-- Probar consulta_usuario_por_usuario
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM comun.consulta_usuario_por_usuario('test_nonexistent');
    RAISE NOTICE '   ✓ consulta_usuario_por_usuario() ejecutado: % registros', v_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '   ✗ ERROR en consulta_usuario_por_usuario(): %', SQLERRM;
END $$;

-- Probar consulta_usuario_por_nombre
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM comun.consulta_usuario_por_nombre('TEST');
    RAISE NOTICE '   ✓ consulta_usuario_por_nombre() ejecutado: % registros', v_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '   ✗ ERROR en consulta_usuario_por_nombre(): %', SQLERRM;
END $$;

-- Probar consulta_usuario_por_depto
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM comun.consulta_usuario_por_depto(1, 1);
    RAISE NOTICE '   ✓ consulta_usuario_por_depto() ejecutado: % registros', v_count;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '   ✗ ERROR en consulta_usuario_por_depto(): %', SQLERRM;
END $$;

-- =====================================================
-- 7. PRUEBA FUNCIONAL BÁSICA - CRUD
-- =====================================================
\echo ''
\echo '7. Probando funcionalidad básica (CRUD)...'

-- Limpiar datos de prueba si existen
DELETE FROM comun.usuarios WHERE usuario = 'verify_test_001';

-- Probar crear_usuario
DO $$
DECLARE
    v_resultado RECORD;
    v_cvedepto INTEGER;
BEGIN
    -- Obtener un departamento válido
    SELECT cvedepto INTO v_cvedepto
    FROM comun.deptos
    LIMIT 1;

    IF v_cvedepto IS NULL THEN
        RAISE NOTICE '   - crear_usuario() omitido (no hay departamentos)';
        RETURN;
    END IF;

    -- Intentar crear usuario
    SELECT * INTO v_resultado
    FROM comun.crear_usuario(
        'verify_test_001',
        'Usuario Verificacion',
        'test123',
        v_cvedepto,
        5,
        'verificacion'
    );

    IF v_resultado.success THEN
        RAISE NOTICE '   ✓ crear_usuario() ejecutado: %', v_resultado.message;
    ELSE
        RAISE NOTICE '   ✗ crear_usuario() falló: %', v_resultado.message;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '   ✗ ERROR en crear_usuario(): %', SQLERRM;
END $$;

-- Probar actualizar_usuario
DO $$
DECLARE
    v_resultado RECORD;
BEGIN
    -- Solo si el usuario existe
    IF EXISTS (SELECT 1 FROM comun.usuarios WHERE usuario = 'verify_test_001') THEN
        SELECT * INTO v_resultado
        FROM comun.actualizar_usuario(
            'verify_test_001',
            'Usuario Verificacion Actualizado',
            NULL,
            1,
            9,
            'verificacion'
        );

        IF v_resultado.success THEN
            RAISE NOTICE '   ✓ actualizar_usuario() ejecutado: %', v_resultado.message;
        ELSE
            RAISE NOTICE '   ✗ actualizar_usuario() falló: %', v_resultado.message;
        END IF;
    ELSE
        RAISE NOTICE '   - actualizar_usuario() omitido (usuario de prueba no creado)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '   ✗ ERROR en actualizar_usuario(): %', SQLERRM;
END $$;

-- Probar dar_baja_usuario
DO $$
DECLARE
    v_resultado RECORD;
BEGIN
    -- Solo si el usuario existe
    IF EXISTS (SELECT 1 FROM comun.usuarios WHERE usuario = 'verify_test_001') THEN
        SELECT * INTO v_resultado
        FROM comun.dar_baja_usuario('verify_test_001', 'verificacion');

        IF v_resultado.success THEN
            RAISE NOTICE '   ✓ dar_baja_usuario() ejecutado: %', v_resultado.message;
        ELSE
            RAISE NOTICE '   ✗ dar_baja_usuario() falló: %', v_resultado.message;
        END IF;
    ELSE
        RAISE NOTICE '   - dar_baja_usuario() omitido (usuario de prueba no creado)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '   ✗ ERROR en dar_baja_usuario(): %', SQLERRM;
END $$;

-- =====================================================
-- 8. LIMPIEZA
-- =====================================================
\echo ''
\echo '8. Limpiando datos de prueba...'

DELETE FROM comun.usuarios WHERE usuario = 'verify_test_001';

\echo '   ✓ Limpieza completada'

-- =====================================================
-- 9. RESUMEN FINAL
-- =====================================================
\echo ''
\echo '================================================='
\echo 'RESUMEN DE VERIFICACIÓN'
\echo '================================================='

DO $$
DECLARE
    v_count_sps INTEGER;
    v_ext_pgcrypto BOOLEAN;
    v_schema_comun BOOLEAN;
    v_tabla_usuarios BOOLEAN;
    v_tabla_deptos BOOLEAN;
    v_tabla_dependencias BOOLEAN;
    v_status TEXT := '';
BEGIN
    -- Contar SPs
    SELECT COUNT(*) INTO v_count_sps
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'comun'
      AND p.proname IN (
        'get_all_usuarios',
        'consulta_usuario_por_usuario',
        'consulta_usuario_por_nombre',
        'consulta_usuario_por_depto',
        'get_dependencias',
        'get_deptos_by_dependencia',
        'crear_usuario',
        'actualizar_usuario',
        'dar_baja_usuario'
      );

    -- Verificar extensión
    SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto')
    INTO v_ext_pgcrypto;

    -- Verificar schema
    SELECT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'comun')
    INTO v_schema_comun;

    -- Verificar tablas
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'comun' AND table_name = 'usuarios'
    ) INTO v_tabla_usuarios;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'comun' AND table_name = 'deptos'
    ) INTO v_tabla_deptos;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'comun' AND table_name = 'c_dependencias'
    ) INTO v_tabla_dependencias;

    -- Determinar estado general
    IF v_count_sps = 9 AND v_ext_pgcrypto AND v_schema_comun AND
       v_tabla_usuarios AND v_tabla_deptos AND v_tabla_dependencias THEN
        v_status := '✓ VERIFICACIÓN EXITOSA';
    ELSIF v_count_sps = 9 THEN
        v_status := '⚠ PARCIALMENTE EXITOSA (todos los SPs OK, pero faltan tablas o extensión)';
    ELSE
        v_status := '✗ VERIFICACIÓN FALLIDA';
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE 'Estado General: %', v_status;
    RAISE NOTICE '';
    RAISE NOTICE 'Detalles:';
    RAISE NOTICE '  - Stored Procedures: % / 9', v_count_sps;
    RAISE NOTICE '  - Extensión pgcrypto: %', CASE WHEN v_ext_pgcrypto THEN 'OK' ELSE 'FALTA' END;
    RAISE NOTICE '  - Schema comun: %', CASE WHEN v_schema_comun THEN 'OK' ELSE 'FALTA' END;
    RAISE NOTICE '  - Tabla usuarios: %', CASE WHEN v_tabla_usuarios THEN 'OK' ELSE 'FALTA' END;
    RAISE NOTICE '  - Tabla deptos: %', CASE WHEN v_tabla_deptos THEN 'OK' ELSE 'FALTA' END;
    RAISE NOTICE '  - Tabla c_dependencias: %', CASE WHEN v_tabla_dependencias THEN 'OK' ELSE 'FALTA' END;
    RAISE NOTICE '';

    IF v_count_sps = 9 THEN
        RAISE NOTICE '✓ Los 9 stored procedures están desplegados correctamente';
        RAISE NOTICE '';
        RAISE NOTICE 'Para pruebas exhaustivas, ejecutar:';
        RAISE NOTICE '  \i CONSULTAUSUARIOS_PRUEBAS.sql';
    ELSE
        RAISE NOTICE '✗ Faltan stored procedures. Ejecutar:';
        RAISE NOTICE '  \i DEPLOY_CONSULTAUSUARIOS_2025-11-20.sql';
    END IF;

    RAISE NOTICE '';
    RAISE NOTICE 'Documentación disponible en:';
    RAISE NOTICE '  CONSULTAUSUARIOS_DOCUMENTACION.md';
    RAISE NOTICE '  CONSULTAUSUARIOS_RESUMEN.txt';
END $$;

\echo '================================================='
\echo ''
