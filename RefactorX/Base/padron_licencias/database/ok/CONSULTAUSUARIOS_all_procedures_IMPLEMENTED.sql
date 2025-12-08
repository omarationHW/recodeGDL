-- =====================================================
-- STORED PROCEDURES COMPLETOS - IMPLEMENTADOS
-- Componente: consultausuariosfrm
-- Módulo: padron_licencias
-- Esquema: comun
-- Total SPs: 9
-- Fecha Implementación: 2025-11-20
-- Estado: IMPLEMENTADO CON LÓGICA REAL
-- =====================================================
--
-- DESCRIPCIÓN:
-- Este archivo contiene todos los stored procedures necesarios para el
-- componente de consulta y gestión de usuarios del sistema. Incluye
-- operaciones de búsqueda, catálogos y CRUD completo.
--
-- OPERACIONES IMPLEMENTADAS:
-- 1. get_all_usuarios - Cargar todos los usuarios del sistema
-- 2. consulta_usuario_por_usuario - Búsqueda por nombre de usuario
-- 3. consulta_usuario_por_nombre - Búsqueda por nombre completo
-- 4. consulta_usuario_por_depto - Búsqueda por departamento
-- 5. get_dependencias - Catálogo de dependencias
-- 6. get_deptos_by_dependencia - Catálogo de departamentos
-- 7. crear_usuario - Crear nuevo usuario
-- 8. actualizar_usuario - Actualizar usuario existente
-- 9. dar_baja_usuario - Dar de baja un usuario
--
-- TABLAS INVOLUCRADAS:
-- - comun.usuarios - Tabla principal de usuarios
-- - comun.deptos - Departamentos
-- - comun.c_dependencias - Dependencias
--
-- COMPATIBILIDAD:
-- - API Genérica: 100% compatible
-- - Convención: Prefijo schema.nombre_funcion
-- - Parámetros: Prefijo p_ para todos los parámetros
-- - Respuestas: Estructuradas con success/message o result set
-- =====================================================

-- =====================================================
-- SP 1/9: get_all_usuarios
-- Tipo: Report
-- Descripción: Obtiene todos los usuarios del sistema con información
--              de su departamento y dependencia
-- Parámetros: Ninguno
-- Retorna: Lista completa de usuarios activos e inactivos
-- =====================================================

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

-- =====================================================
-- SP 2/9: consulta_usuario_por_usuario
-- Tipo: Report
-- Descripción: Busca un usuario específico por su nombre de usuario
-- Parámetros: p_usuario (VARCHAR) - Nombre de usuario exacto
-- Retorna: Información completa del usuario encontrado
-- =====================================================

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

-- =====================================================
-- SP 3/9: consulta_usuario_por_nombre
-- Tipo: Report
-- Descripción: Busca usuarios por coincidencia de nombre completo
-- Parámetros: p_nombre (VARCHAR) - Prefijo del nombre a buscar
-- Retorna: Lista de usuarios que coinciden con el criterio
-- =====================================================

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

-- =====================================================
-- SP 4/9: consulta_usuario_por_depto
-- Tipo: Report
-- Descripción: Busca usuarios por dependencia y departamento
-- Parámetros:
--   p_id_dependencia (INTEGER) - ID de la dependencia
--   p_cvedepto (INTEGER) - Clave del departamento
-- Retorna: Lista de usuarios del departamento especificado
-- =====================================================

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

-- =====================================================
-- SP 5/9: get_dependencias
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de dependencias
-- Parámetros: Ninguno
-- Retorna: Lista de dependencias ordenadas por descripción
-- =====================================================

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

-- =====================================================
-- SP 6/9: get_deptos_by_dependencia
-- Tipo: Catalog
-- Descripción: Obtiene los departamentos de una dependencia específica
-- Parámetros: p_id_dependencia (INTEGER) - ID de la dependencia
-- Retorna: Lista de departamentos de la dependencia
-- =====================================================

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

-- =====================================================
-- SP 7/9: crear_usuario
-- Tipo: CRUD (Create)
-- Descripción: Crea un nuevo usuario en el sistema
-- Parámetros:
--   p_usuario (VARCHAR) - Nombre de usuario
--   p_nombres (VARCHAR) - Nombre completo
--   p_clave (VARCHAR) - Contraseña (será hasheada con bcrypt)
--   p_cvedepto (INTEGER) - Clave del departamento
--   p_nivel (INTEGER) - Nivel de acceso (1, 5, 9, 10)
--   p_capturo (VARCHAR) - Usuario que registra
-- Retorna: success (BOOLEAN), message (TEXT)
-- =====================================================

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
    -- Nota: Requiere extensión pgcrypto
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

-- =====================================================
-- SP 8/9: actualizar_usuario
-- Tipo: CRUD (Update)
-- Descripción: Actualiza los datos de un usuario existente
-- Parámetros:
--   p_usuario (VARCHAR) - Nombre de usuario (identificador)
--   p_nombres (VARCHAR) - Nombre completo
--   p_clave (VARCHAR) - Nueva contraseña (NULL para mantener actual)
--   p_cvedepto (INTEGER) - Clave del departamento
--   p_nivel (INTEGER) - Nivel de acceso
--   p_capturo (VARCHAR) - Usuario que modifica (no usado actualmente)
-- Retorna: success (BOOLEAN), message (TEXT)
-- =====================================================

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

-- =====================================================
-- SP 9/9: dar_baja_usuario
-- Tipo: CRUD (Soft Delete)
-- Descripción: Da de baja un usuario (marca fecha de baja)
-- Parámetros:
--   p_usuario (VARCHAR) - Nombre de usuario
--   p_capturo (VARCHAR) - Usuario que realiza la baja (no usado)
-- Retorna: success (BOOLEAN), message (TEXT)
-- =====================================================

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
-- NOTAS IMPORTANTES PARA IMPLEMENTACIÓN
-- =====================================================
--
-- 1. EXTENSIÓN REQUERIDA:
--    Estos SPs utilizan pgcrypto para hash de contraseñas (bcrypt)
--    Asegúrate de tener la extensión habilitada:
--    CREATE EXTENSION IF NOT EXISTS pgcrypto;
--
-- 2. ESTRUCTURA DE TABLAS:
--    Las tablas deben existir en el schema 'comun':
--    - comun.usuarios
--    - comun.deptos
--    - comun.c_dependencias
--
-- 3. CAMPOS IMPORTANTES:
--    comun.usuarios:
--      - usuario (VARCHAR, PK)
--      - nombres (VARCHAR)
--      - clave (VARCHAR) - Hash bcrypt
--      - cvedepto (INTEGER, FK)
--      - nivel (INTEGER) - 1, 5, 9, 10
--      - fecalt (DATE)
--      - fecbaj (DATE) - NULL = activo
--      - feccap (TIMESTAMP)
--      - capturo (VARCHAR)
--
-- 4. SEGURIDAD:
--    - Todas las contraseñas se hashean con bcrypt (factor 8)
--    - Los nombres de usuario se almacenan en lowercase
--    - Los nombres completos se almacenan en uppercase
--    - Las búsquedas son case-insensitive
--
-- 5. COMPATIBILIDAD API:
--    - Todos los SPs usan prefijo de schema: comun.nombre_funcion
--    - Todos los parámetros usan prefijo: p_
--    - SPs de escritura retornan: TABLE(success BOOLEAN, message TEXT)
--    - SPs de lectura retornan: TABLE con columnas específicas
--
-- 6. VALIDACIONES:
--    - Usuario único (no duplicados)
--    - Departamento válido (debe existir)
--    - Nivel válido (1, 5, 9, 10)
--    - No dar de baja usuarios ya dados de baja
--    - Contraseñas opcionales en UPDATE (mantiene actual si NULL)
--
-- =====================================================
-- FIN DEL ARCHIVO
-- =====================================================
