-- =====================================================
-- SCRIPT DE DEPLOYMENT
-- Componente: consultausuariosfrm
-- Módulo: padron_licencias
-- Esquema: comun
-- Total SPs: 9
-- Fecha: 2025-11-20
-- =====================================================
--
-- INSTRUCCIONES DE DEPLOYMENT:
-- 1. Verificar que el schema 'comun' existe
-- 2. Habilitar extensión pgcrypto si no está disponible
-- 3. Ejecutar este script en la base de datos guadalajara
-- 4. Verificar que todos los SPs se crearon correctamente
--
-- PREREQUISITOS:
-- - Base de datos: guadalajara
-- - Schema: comun
-- - Extensión: pgcrypto (para bcrypt)
-- - Tablas: comun.usuarios, comun.deptos, comun.c_dependencias
-- =====================================================

-- =====================================================
-- PASO 1: VERIFICAR/CREAR SCHEMA
-- =====================================================
CREATE SCHEMA IF NOT EXISTS comun;

-- =====================================================
-- PASO 2: HABILITAR EXTENSIÓN PGCRYPTO
-- =====================================================
-- Esta extensión es necesaria para el hash de contraseñas con bcrypt
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Verificar que la extensión está disponible
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN
        RAISE NOTICE 'ADVERTENCIA: La extensión pgcrypto no está disponible. Los SPs de creación y actualización de usuarios fallarán.';
    ELSE
        RAISE NOTICE 'Extensión pgcrypto verificada correctamente.';
    END IF;
END $$;

-- =====================================================
-- PASO 3: DEPLOYMENT DE STORED PROCEDURES
-- =====================================================

-- SP 1/9: get_all_usuarios
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS comun.get_all_usuarios() CASCADE;

CREATE OR REPLACE FUNCTION comun.get_all_usuarios()
RETURNS TABLE (
    usuario VARCHAR,
    nombres VARCHAR,
    cvedepto INTEGER,
    nivel INTEGER,
    fecalt DATE,
    fecbaj DATE,
    feccap TIMESTAMP,
    capturo VARCHAR,
    nombredepto VARCHAR,
    telefono VARCHAR,
    cvedependencia INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.usuario,
        u.nombres,
        u.cvedepto,
        u.nivel,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo,
        d.nombredepto,
        d.telefono,
        d.cvedependencia,
        dep.descripcion
    FROM comun.usuarios u
    LEFT JOIN comun.deptos d ON u.cvedepto = d.cvedepto
    LEFT JOIN comun.c_dependencias dep ON d.cvedependencia = dep.id_dependencia
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.get_all_usuarios() IS 'Obtiene lista completa de usuarios con su información de departamento y dependencia';

-- SP 2/9: consulta_usuario_por_usuario
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS comun.consulta_usuario_por_usuario(VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_usuario(p_usuario VARCHAR)
RETURNS TABLE (
    descripcion VARCHAR,
    nombredepto VARCHAR,
    telefono VARCHAR,
    usuario VARCHAR,
    nombres VARCHAR,
    fecalt DATE,
    fecbaj DATE,
    feccap TIMESTAMP,
    capturo VARCHAR,
    cvedepto INTEGER,
    nivel INTEGER,
    cvedependencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.descripcion,
        d.nombredepto,
        d.telefono,
        u.usuario,
        u.nombres,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo,
        u.cvedepto,
        u.nivel,
        d.cvedependencia
    FROM comun.usuarios u
    LEFT JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    LEFT JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE LOWER(u.usuario) = LOWER(p_usuario);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.consulta_usuario_por_usuario(VARCHAR) IS 'Busca un usuario por su nombre de usuario exacto (case-insensitive)';

-- SP 3/9: consulta_usuario_por_nombre
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS comun.consulta_usuario_por_nombre(VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_nombre(p_nombre VARCHAR)
RETURNS TABLE (
    descripcion VARCHAR,
    nombredepto VARCHAR,
    telefono VARCHAR,
    usuario VARCHAR,
    nombres VARCHAR,
    fecalt DATE,
    fecbaj DATE,
    feccap TIMESTAMP,
    capturo VARCHAR,
    cvedepto INTEGER,
    nivel INTEGER,
    cvedependencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.descripcion,
        d.nombredepto,
        d.telefono,
        u.usuario,
        u.nombres,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo,
        u.cvedepto,
        u.nivel,
        d.cvedependencia
    FROM comun.usuarios u
    LEFT JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    LEFT JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE u.nombres ILIKE p_nombre || '%'
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.consulta_usuario_por_nombre(VARCHAR) IS 'Busca usuarios por coincidencia de nombre (búsqueda por prefijo, case-insensitive)';

-- SP 4/9: consulta_usuario_por_depto
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS comun.consulta_usuario_por_depto(INTEGER, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_depto(
    p_id_dependencia INTEGER,
    p_cvedepto INTEGER
)
RETURNS TABLE (
    descripcion VARCHAR,
    nombredepto VARCHAR,
    telefono VARCHAR,
    usuario VARCHAR,
    nombres VARCHAR,
    fecalt DATE,
    fecbaj DATE,
    feccap TIMESTAMP,
    capturo VARCHAR,
    cvedepto INTEGER,
    nivel INTEGER,
    cvedependencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.descripcion,
        d.nombredepto,
        d.telefono,
        u.usuario,
        u.nombres,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo,
        u.cvedepto,
        u.nivel,
        d.cvedependencia
    FROM comun.usuarios u
    LEFT JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    LEFT JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE d.cvedependencia = p_id_dependencia
      AND d.cvedepto = p_cvedepto
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.consulta_usuario_por_depto(INTEGER, INTEGER) IS 'Busca usuarios por dependencia y departamento específico';

-- SP 5/9: get_dependencias
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS comun.get_dependencias() CASCADE;

CREATE OR REPLACE FUNCTION comun.get_dependencias()
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion VARCHAR,
    clave VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id_dependencia,
        c.descripcion,
        c.clave
    FROM comun.c_dependencias c
    ORDER BY c.descripcion;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.get_dependencias() IS 'Catálogo de dependencias ordenadas alfabéticamente';

-- SP 6/9: get_deptos_by_dependencia
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS comun.get_deptos_by_dependencia(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION comun.get_deptos_by_dependencia(p_id_dependencia INTEGER)
RETURNS TABLE (
    cvedepto INTEGER,
    nombredepto VARCHAR,
    telefono VARCHAR,
    cvedependencia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.cvedepto,
        d.nombredepto,
        d.telefono,
        d.cvedependencia
    FROM comun.deptos d
    WHERE d.cvedependencia = p_id_dependencia
    ORDER BY d.nombredepto;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.get_deptos_by_dependencia(INTEGER) IS 'Obtiene departamentos de una dependencia específica';

-- SP 7/9: crear_usuario
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS comun.crear_usuario(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.crear_usuario(
    p_usuario VARCHAR,
    p_nombres VARCHAR,
    p_clave VARCHAR,
    p_cvedepto INTEGER,
    p_nivel INTEGER,
    p_capturo VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_usuario_existente VARCHAR;
    v_hashed_password TEXT;
BEGIN
    -- Validar que el usuario no exista
    SELECT u.usuario INTO v_usuario_existente
    FROM comun.usuarios u
    WHERE LOWER(u.usuario) = LOWER(p_usuario);

    IF v_usuario_existente IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, 'El usuario ya existe'::TEXT;
        RETURN;
    END IF;

    -- Validar que el departamento exista
    IF NOT EXISTS (SELECT 1 FROM comun.deptos WHERE cvedepto = p_cvedepto) THEN
        RETURN QUERY SELECT FALSE, 'El departamento especificado no existe'::TEXT;
        RETURN;
    END IF;

    -- Validar nivel (debe ser 1, 5, 9 o 10)
    IF p_nivel NOT IN (1, 5, 9, 10) THEN
        RETURN QUERY SELECT FALSE, 'El nivel debe ser 1, 5, 9 o 10'::TEXT;
        RETURN;
    END IF;

    -- Hash de la contraseña con bcrypt (salt factor 8)
    v_hashed_password := crypt(p_clave, gen_salt('bf', 8));

    -- Insertar usuario
    INSERT INTO comun.usuarios (
        usuario,
        nombres,
        clave,
        cvedepto,
        nivel,
        fecalt,
        feccap,
        capturo
    ) VALUES (
        LOWER(p_usuario),
        UPPER(p_nombres),
        v_hashed_password,
        p_cvedepto,
        p_nivel,
        CURRENT_DATE,
        NOW(),
        p_capturo
    );

    RETURN QUERY SELECT TRUE, 'Usuario creado exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al crear usuario: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.crear_usuario(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, VARCHAR) IS 'Crea un nuevo usuario con contraseña hasheada (bcrypt)';

-- SP 8/9: actualizar_usuario
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS comun.actualizar_usuario(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.actualizar_usuario(
    p_usuario VARCHAR,
    p_nombres VARCHAR,
    p_clave VARCHAR,
    p_cvedepto INTEGER,
    p_nivel INTEGER,
    p_capturo VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_hashed_password TEXT;
    v_usuario_existe BOOLEAN;
    v_rows_affected INTEGER;
BEGIN
    -- Verificar que el usuario existe
    SELECT EXISTS(
        SELECT 1 FROM comun.usuarios WHERE LOWER(usuario) = LOWER(p_usuario)
    ) INTO v_usuario_existe;

    IF NOT v_usuario_existe THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT;
        RETURN;
    END IF;

    -- Validar que el departamento exista
    IF NOT EXISTS (SELECT 1 FROM comun.deptos WHERE cvedepto = p_cvedepto) THEN
        RETURN QUERY SELECT FALSE, 'El departamento especificado no existe'::TEXT;
        RETURN;
    END IF;

    -- Validar nivel
    IF p_nivel NOT IN (1, 5, 9, 10) THEN
        RETURN QUERY SELECT FALSE, 'El nivel debe ser 1, 5, 9 o 10'::TEXT;
        RETURN;
    END IF;

    -- Si se proporciona nueva clave, hashearla
    IF p_clave IS NOT NULL AND LENGTH(TRIM(p_clave)) > 0 THEN
        v_hashed_password := crypt(p_clave, gen_salt('bf', 8));

        UPDATE comun.usuarios
        SET nombres = UPPER(p_nombres),
            clave = v_hashed_password,
            cvedepto = p_cvedepto,
            nivel = p_nivel
        WHERE LOWER(usuario) = LOWER(p_usuario);
    ELSE
        -- No actualizar la clave
        UPDATE comun.usuarios
        SET nombres = UPPER(p_nombres),
            cvedepto = p_cvedepto,
            nivel = p_nivel
        WHERE LOWER(usuario) = LOWER(p_usuario);
    END IF;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT TRUE, 'Usuario actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo actualizar el usuario'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al actualizar usuario: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.actualizar_usuario(VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER, VARCHAR) IS 'Actualiza los datos de un usuario. Si p_clave es NULL o vacío, mantiene la contraseña actual';

-- SP 9/9: dar_baja_usuario
-- -----------------------------------------------------
DROP FUNCTION IF EXISTS comun.dar_baja_usuario(VARCHAR, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.dar_baja_usuario(
    p_usuario VARCHAR,
    p_capturo VARCHAR
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_usuario_existe BOOLEAN;
    v_ya_dado_baja BOOLEAN;
    v_rows_affected INTEGER;
BEGIN
    -- Verificar que el usuario existe
    SELECT EXISTS(
        SELECT 1 FROM comun.usuarios WHERE LOWER(usuario) = LOWER(p_usuario)
    ) INTO v_usuario_existe;

    IF NOT v_usuario_existe THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT;
        RETURN;
    END IF;

    -- Verificar si ya está dado de baja
    SELECT EXISTS(
        SELECT 1 FROM comun.usuarios
        WHERE LOWER(usuario) = LOWER(p_usuario)
          AND fecbaj IS NOT NULL
    ) INTO v_ya_dado_baja;

    IF v_ya_dado_baja THEN
        RETURN QUERY SELECT FALSE, 'El usuario ya está dado de baja'::TEXT;
        RETURN;
    END IF;

    -- Dar de baja (marcar fecha)
    UPDATE comun.usuarios
    SET fecbaj = CURRENT_DATE
    WHERE LOWER(usuario) = LOWER(p_usuario)
      AND fecbaj IS NULL;

    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;

    IF v_rows_affected > 0 THEN
        RETURN QUERY SELECT TRUE, 'Usuario dado de baja exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo dar de baja al usuario'::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al dar de baja usuario: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.dar_baja_usuario(VARCHAR, VARCHAR) IS 'Da de baja un usuario marcando la fecha de baja (soft delete)';

-- =====================================================
-- PASO 4: VERIFICACIÓN DE DEPLOYMENT
-- =====================================================

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
    v_missing TEXT[] := ARRAY[]::TEXT[];
BEGIN
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'VERIFICACIÓN DE STORED PROCEDURES';
    RAISE NOTICE 'Schema: comun';
    RAISE NOTICE 'Total esperado: 9 SPs';
    RAISE NOTICE '===========================================';

    FOREACH v_sp IN ARRAY v_sps
    LOOP
        SELECT COUNT(*) INTO v_count
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
          AND p.proname = v_sp;

        IF v_count > 0 THEN
            RAISE NOTICE '✓ comun.% - OK', v_sp;
        ELSE
            RAISE NOTICE '✗ comun.% - FALTANTE', v_sp;
            v_missing := array_append(v_missing, v_sp);
        END IF;
    END LOOP;

    RAISE NOTICE '===========================================';

    IF array_length(v_missing, 1) IS NULL THEN
        RAISE NOTICE '✓ DEPLOYMENT EXITOSO - Todos los SPs fueron creados';
    ELSE
        RAISE NOTICE '✗ DEPLOYMENT INCOMPLETO - Faltan % SPs', array_length(v_missing, 1);
        RAISE NOTICE 'SPs faltantes: %', array_to_string(v_missing, ', ');
    END IF;

    RAISE NOTICE '===========================================';
END $$;

-- =====================================================
-- FIN DEL SCRIPT DE DEPLOYMENT
-- =====================================================
