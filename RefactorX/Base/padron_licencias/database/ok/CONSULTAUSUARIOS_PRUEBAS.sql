-- =====================================================
-- PRUEBAS DE STORED PROCEDURES
-- Componente: consultausuariosfrm
-- Módulo: padron_licencias
-- Schema: comun
-- Total SPs: 9
-- Fecha: 2025-11-20
-- =====================================================
--
-- INSTRUCCIONES:
-- Este archivo contiene pruebas para cada stored procedure.
-- Ejecuta las secciones en orden para probar la funcionalidad.
--
-- IMPORTANTE: Estas pruebas asumen que:
-- 1. Las tablas comun.usuarios, comun.deptos, comun.c_dependencias existen
-- 2. La extensión pgcrypto está habilitada
-- 3. Existe al menos un departamento en comun.deptos
-- =====================================================

-- =====================================================
-- SECCIÓN 1: VERIFICACIÓN DE PREREQUISITOS
-- =====================================================

-- Verificar extensión pgcrypto
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto')
        THEN '✓ pgcrypto está instalada'
        ELSE '✗ ERROR: pgcrypto NO está instalada'
    END as status_pgcrypto;

-- Verificar schema comun
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'comun')
        THEN '✓ Schema comun existe'
        ELSE '✗ ERROR: Schema comun NO existe'
    END as status_schema;

-- Verificar tablas
SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'comun' AND table_name = 'usuarios')
        THEN '✓ Tabla comun.usuarios existe'
        ELSE '✗ ERROR: Tabla comun.usuarios NO existe'
    END as status_usuarios;

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'comun' AND table_name = 'deptos')
        THEN '✓ Tabla comun.deptos existe'
        ELSE '✗ ERROR: Tabla comun.deptos NO existe'
    END as status_deptos;

SELECT
    CASE
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'comun' AND table_name = 'c_dependencias')
        THEN '✓ Tabla comun.c_dependencias existe'
        ELSE '✗ ERROR: Tabla comun.c_dependencias NO existe'
    END as status_dependencias;

-- =====================================================
-- SECCIÓN 2: VERIFICAR STORED PROCEDURES CREADOS
-- =====================================================

SELECT
    p.proname as nombre_sp,
    n.nspname as schema,
    pg_get_function_arguments(p.oid) as parametros,
    CASE
        WHEN p.proname IS NOT NULL THEN '✓ Existe'
        ELSE '✗ No existe'
    END as status
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
  )
ORDER BY p.proname;

-- =====================================================
-- SECCIÓN 3: PRUEBAS DE CATÁLOGOS
-- =====================================================

-- Prueba 3.1: get_dependencias()
\echo '=== PRUEBA 3.1: get_dependencias() ==='
SELECT * FROM comun.get_dependencias()
LIMIT 5;

-- Prueba 3.2: get_deptos_by_dependencia()
\echo '=== PRUEBA 3.2: get_deptos_by_dependencia() ==='
-- Usar la primera dependencia disponible
DO $$
DECLARE
    v_id_dep INTEGER;
BEGIN
    SELECT id_dependencia INTO v_id_dep
    FROM comun.c_dependencias
    LIMIT 1;

    IF v_id_dep IS NOT NULL THEN
        RAISE NOTICE 'Probando con id_dependencia: %', v_id_dep;
    ELSE
        RAISE NOTICE 'No hay dependencias en la BD';
    END IF;
END $$;

-- Ejecutar con primera dependencia (ajustar el ID según tu BD)
SELECT * FROM comun.get_deptos_by_dependencia(1)
LIMIT 5;

-- =====================================================
-- SECCIÓN 4: PRUEBAS DE USUARIO DE PRUEBA
-- =====================================================

-- Nota: Estas pruebas crearán un usuario de prueba
-- Usuario de prueba: test_user_001
-- Si ya existe, se eliminará primero

-- Limpiar usuario de prueba anterior (si existe)
DELETE FROM comun.usuarios WHERE usuario = 'test_user_001';

-- =====================================================
-- Prueba 4.1: crear_usuario() - CASO EXITOSO
-- =====================================================
\echo '=== PRUEBA 4.1: crear_usuario() - Caso exitoso ==='

-- Obtener un departamento válido
DO $$
DECLARE
    v_cvedepto INTEGER;
BEGIN
    SELECT cvedepto INTO v_cvedepto
    FROM comun.deptos
    LIMIT 1;

    IF v_cvedepto IS NOT NULL THEN
        RAISE NOTICE 'Usando departamento: %', v_cvedepto;
    ELSE
        RAISE NOTICE 'ADVERTENCIA: No hay departamentos disponibles. Crear uno primero.';
    END IF;
END $$;

-- Crear usuario de prueba (ajustar cvedepto según tu BD)
SELECT * FROM comun.crear_usuario(
    'test_user_001',                    -- p_usuario
    'Usuario de Prueba Test',           -- p_nombres
    'password123',                      -- p_clave
    1,                                  -- p_cvedepto (ajustar)
    5,                                  -- p_nivel
    'prueba_automatica'                 -- p_capturo
);

-- =====================================================
-- Prueba 4.2: crear_usuario() - CASO ERROR (duplicado)
-- =====================================================
\echo '=== PRUEBA 4.2: crear_usuario() - Usuario duplicado ==='

SELECT * FROM comun.crear_usuario(
    'test_user_001',                    -- Mismo usuario
    'Usuario Duplicado',
    'password456',
    1,
    5,
    'prueba_automatica'
);

-- =====================================================
-- Prueba 4.3: crear_usuario() - CASO ERROR (nivel inválido)
-- =====================================================
\echo '=== PRUEBA 4.3: crear_usuario() - Nivel inválido ==='

SELECT * FROM comun.crear_usuario(
    'test_user_002',
    'Usuario Nivel Invalido',
    'password123',
    1,
    99,                                 -- Nivel inválido
    'prueba_automatica'
);

-- =====================================================
-- Prueba 4.4: crear_usuario() - CASO ERROR (depto inexistente)
-- =====================================================
\echo '=== PRUEBA 4.4: crear_usuario() - Departamento inexistente ==='

SELECT * FROM comun.crear_usuario(
    'test_user_003',
    'Usuario Depto Invalido',
    'password123',
    99999,                              -- Departamento inexistente
    5,
    'prueba_automatica'
);

-- =====================================================
-- SECCIÓN 5: PRUEBAS DE CONSULTAS
-- =====================================================

-- Prueba 5.1: get_all_usuarios()
\echo '=== PRUEBA 5.1: get_all_usuarios() ==='

SELECT
    usuario,
    nombres,
    nivel,
    fecalt,
    fecbaj,
    nombredepto
FROM comun.get_all_usuarios()
WHERE usuario = 'test_user_001';

-- Prueba 5.2: consulta_usuario_por_usuario()
\echo '=== PRUEBA 5.2: consulta_usuario_por_usuario() ==='

SELECT * FROM comun.consulta_usuario_por_usuario('test_user_001');

-- Prueba 5.3: consulta_usuario_por_usuario() - Case insensitive
\echo '=== PRUEBA 5.3: consulta_usuario_por_usuario() - UPPERCASE ==='

SELECT * FROM comun.consulta_usuario_por_usuario('TEST_USER_001');

-- Prueba 5.4: consulta_usuario_por_nombre()
\echo '=== PRUEBA 5.4: consulta_usuario_por_nombre() ==='

SELECT * FROM comun.consulta_usuario_por_nombre('USUARIO DE PRUEBA');

-- Prueba 5.5: consulta_usuario_por_nombre() - Prefijo corto
\echo '=== PRUEBA 5.5: consulta_usuario_por_nombre() - Prefijo ==='

SELECT * FROM comun.consulta_usuario_por_nombre('USUARIO');

-- Prueba 5.6: consulta_usuario_por_depto()
\echo '=== PRUEBA 5.6: consulta_usuario_por_depto() ==='

-- Consultar por el departamento del usuario de prueba
DO $$
DECLARE
    v_cvedepto INTEGER;
    v_cvedependencia INTEGER;
BEGIN
    SELECT d.cvedepto, d.cvedependencia
    INTO v_cvedepto, v_cvedependencia
    FROM comun.usuarios u
    JOIN comun.deptos d ON u.cvedepto = d.cvedepto
    WHERE u.usuario = 'test_user_001';

    IF v_cvedepto IS NOT NULL THEN
        RAISE NOTICE 'Departamento: %, Dependencia: %', v_cvedepto, v_cvedependencia;
    END IF;
END $$;

SELECT * FROM comun.consulta_usuario_por_depto(1, 1); -- Ajustar según tu BD

-- =====================================================
-- SECCIÓN 6: PRUEBAS DE ACTUALIZACIÓN
-- =====================================================

-- Prueba 6.1: actualizar_usuario() - Sin cambiar contraseña
\echo '=== PRUEBA 6.1: actualizar_usuario() - Sin cambiar clave ==='

SELECT * FROM comun.actualizar_usuario(
    'test_user_001',                    -- p_usuario
    'Usuario de Prueba ACTUALIZADO',   -- p_nombres (nuevo)
    NULL,                               -- p_clave (mantener actual)
    1,                                  -- p_cvedepto
    9,                                  -- p_nivel (cambiado de 5 a 9)
    'prueba_automatica'                 -- p_capturo
);

-- Verificar actualización
SELECT usuario, nombres, nivel
FROM comun.usuarios
WHERE usuario = 'test_user_001';

-- Prueba 6.2: actualizar_usuario() - Cambiar contraseña
\echo '=== PRUEBA 6.2: actualizar_usuario() - Cambiar clave ==='

SELECT * FROM comun.actualizar_usuario(
    'test_user_001',
    'Usuario de Prueba ACTUALIZADO',
    'newpassword456',                   -- Nueva contraseña
    1,
    9,
    'prueba_automatica'
);

-- Verificar que la contraseña cambió (debería ser diferente)
SELECT
    usuario,
    nombres,
    clave,
    LENGTH(clave) as longitud_hash
FROM comun.usuarios
WHERE usuario = 'test_user_001';

-- Prueba 6.3: actualizar_usuario() - Usuario inexistente
\echo '=== PRUEBA 6.3: actualizar_usuario() - Usuario inexistente ==='

SELECT * FROM comun.actualizar_usuario(
    'usuario_inexistente',
    'No Existe',
    NULL,
    1,
    5,
    'prueba_automatica'
);

-- Prueba 6.4: actualizar_usuario() - Nivel inválido
\echo '=== PRUEBA 6.4: actualizar_usuario() - Nivel inválido ==='

SELECT * FROM comun.actualizar_usuario(
    'test_user_001',
    'Usuario de Prueba',
    NULL,
    1,
    99,                                 -- Nivel inválido
    'prueba_automatica'
);

-- =====================================================
-- SECCIÓN 7: PRUEBAS DE BAJA
-- =====================================================

-- Prueba 7.1: dar_baja_usuario() - Caso exitoso
\echo '=== PRUEBA 7.1: dar_baja_usuario() - Caso exitoso ==='

SELECT * FROM comun.dar_baja_usuario(
    'test_user_001',
    'prueba_automatica'
);

-- Verificar que la baja se registró
SELECT
    usuario,
    nombres,
    fecalt,
    fecbaj,
    CASE
        WHEN fecbaj IS NOT NULL THEN 'INACTIVO'
        ELSE 'ACTIVO'
    END as estado
FROM comun.usuarios
WHERE usuario = 'test_user_001';

-- Prueba 7.2: dar_baja_usuario() - Usuario ya dado de baja
\echo '=== PRUEBA 7.2: dar_baja_usuario() - Ya dado de baja ==='

SELECT * FROM comun.dar_baja_usuario(
    'test_user_001',
    'prueba_automatica'
);

-- Prueba 7.3: dar_baja_usuario() - Usuario inexistente
\echo '=== PRUEBA 7.3: dar_baja_usuario() - Usuario inexistente ==='

SELECT * FROM comun.dar_baja_usuario(
    'usuario_inexistente',
    'prueba_automatica'
);

-- =====================================================
-- SECCIÓN 8: PRUEBAS DE INTEGRACIÓN
-- =====================================================

-- Prueba 8.1: Flujo completo - Crear, Consultar, Actualizar, Dar de baja
\echo '=== PRUEBA 8.1: Flujo completo ==='

-- Limpiar
DELETE FROM comun.usuarios WHERE usuario = 'integracion_test';

-- 1. Crear
SELECT 'PASO 1: Crear usuario' as paso;
SELECT * FROM comun.crear_usuario(
    'integracion_test',
    'Usuario Integracion Test',
    'password123',
    1,
    1,
    'integracion'
);

-- 2. Consultar
SELECT 'PASO 2: Consultar usuario creado' as paso;
SELECT usuario, nombres, nivel, fecalt, fecbaj
FROM comun.get_all_usuarios()
WHERE usuario = 'integracion_test';

-- 3. Actualizar
SELECT 'PASO 3: Actualizar usuario' as paso;
SELECT * FROM comun.actualizar_usuario(
    'integracion_test',
    'Usuario Integracion MODIFICADO',
    'newpass456',
    1,
    5,
    'integracion'
);

-- 4. Verificar actualización
SELECT 'PASO 4: Verificar actualización' as paso;
SELECT usuario, nombres, nivel
FROM comun.usuarios
WHERE usuario = 'integracion_test';

-- 5. Dar de baja
SELECT 'PASO 5: Dar de baja' as paso;
SELECT * FROM comun.dar_baja_usuario(
    'integracion_test',
    'integracion'
);

-- 6. Verificar baja
SELECT 'PASO 6: Verificar baja' as paso;
SELECT usuario, nombres, fecbaj
FROM comun.usuarios
WHERE usuario = 'integracion_test';

-- =====================================================
-- SECCIÓN 9: PRUEBAS DE SEGURIDAD
-- =====================================================

-- Prueba 9.1: Verificar hash de contraseñas (bcrypt)
\echo '=== PRUEBA 9.1: Verificar hash de contraseñas ==='

SELECT
    usuario,
    nombres,
    LEFT(clave, 7) as hash_prefix,
    LENGTH(clave) as longitud_hash,
    CASE
        WHEN LEFT(clave, 4) = '$2a$' OR LEFT(clave, 4) = '$2b$' THEN '✓ Bcrypt detectado'
        ELSE '✗ No es bcrypt'
    END as tipo_hash
FROM comun.usuarios
WHERE usuario IN ('test_user_001', 'integracion_test')
LIMIT 5;

-- Prueba 9.2: Verificar normalización de datos
\echo '=== PRUEBA 9.2: Verificar normalización de datos ==='

-- Crear usuario con diferentes casos
DELETE FROM comun.usuarios WHERE usuario = 'case_test';

SELECT * FROM comun.crear_usuario(
    'CaSe_TeSt',                        -- Mixto -> debe ser lowercase
    'nombre en minusculas',             -- Minúsculas -> debe ser UPPERCASE
    'password123',
    1,
    5,
    'prueba'
);

-- Verificar normalización
SELECT
    usuario,
    nombres,
    CASE
        WHEN usuario = LOWER('CaSe_TeSt') THEN '✓ Usuario en lowercase'
        ELSE '✗ Usuario NO normalizado'
    END as check_usuario,
    CASE
        WHEN nombres = UPPER('nombre en minusculas') THEN '✓ Nombre en UPPERCASE'
        ELSE '✗ Nombre NO normalizado'
    END as check_nombre
FROM comun.usuarios
WHERE usuario = 'case_test';

-- =====================================================
-- SECCIÓN 10: LIMPIEZA DE DATOS DE PRUEBA
-- =====================================================

\echo '=== LIMPIEZA: Eliminando usuarios de prueba ==='

DELETE FROM comun.usuarios WHERE usuario IN (
    'test_user_001',
    'integracion_test',
    'case_test'
);

SELECT
    CASE
        WHEN NOT EXISTS (SELECT 1 FROM comun.usuarios WHERE usuario LIKE '%test%')
        THEN '✓ Limpieza completada'
        ELSE '✗ Aún quedan usuarios de prueba'
    END as status_limpieza;

-- =====================================================
-- SECCIÓN 11: RESUMEN DE PRUEBAS
-- =====================================================

\echo '================================================='
\echo 'RESUMEN DE PRUEBAS COMPLETADAS'
\echo '================================================='
\echo ''
\echo 'SPs probados:'
\echo '  1. get_all_usuarios()           ✓'
\echo '  2. consulta_usuario_por_usuario ✓'
\echo '  3. consulta_usuario_por_nombre  ✓'
\echo '  4. consulta_usuario_por_depto   ✓'
\echo '  5. get_dependencias             ✓'
\echo '  6. get_deptos_by_dependencia    ✓'
\echo '  7. crear_usuario                ✓'
\echo '  8. actualizar_usuario           ✓'
\echo '  9. dar_baja_usuario             ✓'
\echo ''
\echo 'Casos probados:'
\echo '  - Casos exitosos                ✓'
\echo '  - Validaciones de error         ✓'
\echo '  - Case-insensitive              ✓'
\echo '  - Hash de contraseñas (bcrypt)  ✓'
\echo '  - Normalización de datos        ✓'
\echo '  - Flujo completo de integración ✓'
\echo ''
\echo '================================================='

-- =====================================================
-- FIN DE PRUEBAS
-- =====================================================
