-- ============================================
-- SCRIPT DE VALIDACIÓN - SP FIRMAUSUARIO
-- Esquema: INFORMIX
-- Base de Datos: padron_licencias
-- Generado: 2025-09-23
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- 1. VALIDACIÓN DE ESTRUCTURA
-- ============================================

-- Verificar que las tablas existen
SELECT
    'Verificación de Tablas' as check_type,
    table_name,
    CASE
        WHEN table_name IS NOT NULL THEN 'EXISTE'
        ELSE 'NO EXISTE'
    END as status
FROM information_schema.tables
WHERE table_schema = 'informix'
  AND table_name IN ('usuarios_autenticacion', 'sesiones_usuarios');

-- Verificar estructura de usuarios_autenticacion
SELECT
    'Estructura usuarios_autenticacion' as table_info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'informix'
  AND table_name = 'usuarios_autenticacion'
ORDER BY ordinal_position;

-- Verificar estructura de sesiones_usuarios
SELECT
    'Estructura sesiones_usuarios' as table_info,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'informix'
  AND table_name = 'sesiones_usuarios'
ORDER BY ordinal_position;

-- ============================================
-- 2. VALIDACIÓN DE FUNCIONES
-- ============================================

-- Verificar que las funciones existen
SELECT
    'Verificación de Funciones' as check_type,
    routine_name,
    routine_type,
    'EXISTE' as status
FROM information_schema.routines
WHERE routine_schema = 'informix'
  AND routine_name LIKE 'sp_firmausuario%'
ORDER BY routine_name;

-- ============================================
-- 3. DATOS DE PRUEBA
-- ============================================

-- Mostrar datos actuales en la tabla
SELECT
    'Datos usuarios_autenticacion' as data_check,
    id,
    usuario,
    CASE WHEN pin IS NOT NULL THEN 'TIENE_PIN' ELSE 'SIN_PIN' END as pin_status,
    estado,
    intentos_fallidos,
    sesion_activa,
    ultimo_acceso,
    observaciones
FROM informix.usuarios_autenticacion
ORDER BY id;

-- Mostrar sesiones
SELECT
    'Datos sesiones_usuarios' as data_check,
    s.id,
    ua.usuario,
    s.fecha_inicio,
    s.fecha_fin,
    s.activa,
    s.ip_address,
    LEFT(s.user_agent, 50) as user_agent_short
FROM informix.sesiones_usuarios s
JOIN informix.usuarios_autenticacion ua ON s.usuario_autenticacion_id = ua.id
ORDER BY s.fecha_inicio DESC;

-- ============================================
-- 4. PRUEBAS FUNCIONALES
-- ============================================

-- Test 1: sp_firmausuario_list - Sin filtros
SELECT '=== TEST 1: sp_firmausuario_list sin filtros ===' as test;
SELECT * FROM informix.sp_firmausuario_list();

-- Test 2: sp_firmausuario_list - Con filtro de usuario
SELECT '=== TEST 2: sp_firmausuario_list con filtro usuario ===' as test;
SELECT * FROM informix.sp_firmausuario_list('admin');

-- Test 3: sp_firmausuario_list - Con filtro de estado activo
SELECT '=== TEST 3: sp_firmausuario_list estado activo ===' as test;
SELECT * FROM informix.sp_firmausuario_list(NULL, 1);

-- Test 4: sp_firmausuario_list - Con paginación
SELECT '=== TEST 4: sp_firmausuario_list con paginación ===' as test;
SELECT * FROM informix.sp_firmausuario_list(NULL, NULL, NULL, 2, 0);

-- Test 5: sp_firmausuario_autenticar - PIN correcto
SELECT '=== TEST 5: sp_firmausuario_autenticar PIN correcto ===' as test;
SELECT * FROM informix.sp_firmausuario_autenticar('admin', '1234');

-- Test 6: sp_firmausuario_autenticar - PIN incorrecto
SELECT '=== TEST 6: sp_firmausuario_autenticar PIN incorrecto ===' as test;
SELECT * FROM informix.sp_firmausuario_autenticar('admin', '9999');

-- Test 7: sp_firmausuario_sesiones - Historial
SELECT '=== TEST 7: sp_firmausuario_sesiones ===' as test;
SELECT * FROM informix.sp_firmausuario_sesiones('admin');

-- Test 8: sp_firmausuario_mantener - Crear usuario
SELECT '=== TEST 8: sp_firmausuario_mantener CREATE ===' as test;
SELECT * FROM informix.sp_firmausuario_mantener('I', NULL, 'nuevousuario', '5555', 1, 0, 'Usuario de prueba creado por validación');

-- Test 9: sp_firmausuario_mantener - Actualizar usuario
SELECT '=== TEST 9: sp_firmausuario_mantener UPDATE ===' as test;
-- Primero obtenemos el ID del usuario recién creado
DO $$
DECLARE
    v_id INTEGER;
BEGIN
    SELECT id INTO v_id FROM informix.usuarios_autenticacion WHERE usuario = 'nuevousuario';
    IF v_id IS NOT NULL THEN
        -- Actualizar observaciones del usuario
        PERFORM informix.sp_firmausuario_mantener('U', v_id, NULL, NULL, 1, 0, 'Usuario actualizado en validación');
        RAISE NOTICE 'Usuario actualizado con ID: %', v_id;
    END IF;
END $$;

-- Test 10: sp_firmausuario_cerrar_sesion
SELECT '=== TEST 10: sp_firmausuario_cerrar_sesion ===' as test;
SELECT * FROM informix.sp_firmausuario_cerrar_sesion('admin');

-- ============================================
-- 5. VALIDACIÓN DE INTEGRIDAD
-- ============================================

-- Verificar que los datos se insertaron correctamente
SELECT
    'Integridad Referencial' as check_type,
    'Usuarios con sesiones' as description,
    COUNT(*) as total
FROM informix.usuarios_autenticacion ua
WHERE EXISTS (
    SELECT 1 FROM informix.sesiones_usuarios s
    WHERE s.usuario_autenticacion_id = ua.id
);

-- Verificar usuarios activos
SELECT
    'Estado de Usuarios' as check_type,
    estado,
    COUNT(*) as total
FROM informix.usuarios_autenticacion
GROUP BY estado;

-- Verificar sesiones activas
SELECT
    'Estado de Sesiones' as check_type,
    activa,
    COUNT(*) as total
FROM informix.sesiones_usuarios
GROUP BY activa;

-- ============================================
-- 6. VALIDACIÓN DE SEGURIDAD
-- ============================================

-- Verificar que los PINs están hasheados (no deben ser texto plano)
SELECT
    'Seguridad PINs' as check_type,
    usuario,
    CASE
        WHEN pin LIKE '$%' THEN 'HASHEADO_OK'
        WHEN LENGTH(pin) < 10 THEN 'POSIBLE_TEXTO_PLANO'
        ELSE 'FORMATO_DESCONOCIDO'
    END as pin_security_status
FROM informix.usuarios_autenticacion;

-- ============================================
-- 7. LIMPIEZA DE DATOS DE PRUEBA
-- ============================================

-- Eliminar el usuario de prueba creado
SELECT '=== LIMPIEZA: Eliminando usuario de prueba ===' as cleanup;
DO $$
DECLARE
    v_id INTEGER;
BEGIN
    SELECT id INTO v_id FROM informix.usuarios_autenticacion WHERE usuario = 'nuevousuario';
    IF v_id IS NOT NULL THEN
        PERFORM informix.sp_firmausuario_mantener('D', v_id);
        RAISE NOTICE 'Usuario de prueba eliminado con ID: %', v_id;
    END IF;
END $$;

-- ============================================
-- 8. RESUMEN FINAL
-- ============================================

SELECT
    'RESUMEN FINAL' as summary_type,
    'Total Usuarios' as metric,
    COUNT(*) as value
FROM informix.usuarios_autenticacion
UNION ALL
SELECT
    'RESUMEN FINAL' as summary_type,
    'Total Sesiones' as metric,
    COUNT(*) as value
FROM informix.sesiones_usuarios
UNION ALL
SELECT
    'RESUMEN FINAL' as summary_type,
    'Usuarios Activos' as metric,
    COUNT(*) as value
FROM informix.usuarios_autenticacion
WHERE estado = 1
UNION ALL
SELECT
    'RESUMEN FINAL' as summary_type,
    'Sesiones Activas' as metric,
    COUNT(*) as value
FROM informix.sesiones_usuarios
WHERE activa = true;

-- ============================================
-- FIN DE VALIDACIÓN
-- ============================================