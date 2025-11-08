-- ============================================
-- STORED PROCEDURES - consultausuariosfrm (CRUD COMPLETO)
-- Base: padron_licencias
-- Esquema: public
-- Fecha: 2025-11-04
-- ============================================
-- Este script crea los 8 SPs necesarios para consultausuariosfrm.vue
-- Basado en el archivo original Delphi consultausuariosfrm.pas
-- Incluye: Consultas (5) + CRUD (3)
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- SECCIÓN 1: SPs DE CONSULTA
-- ============================================

-- SP 1/8: get_dependencias
-- Descripción: Devuelve todas las dependencias ordenadas por descripción
-- ============================================
CREATE OR REPLACE FUNCTION get_dependencias()
RETURNS TABLE (
    id_dependencia integer,
    descripcion varchar,
    clave varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_dependencia, descripcion, clave
    FROM c_dependencias
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_dependencias() IS 'Catálogo de dependencias para consultausuariosfrm';

-- SP 2/8: get_deptos_by_dependencia
-- Descripción: Devuelve departamentos de una dependencia específica
-- ============================================
CREATE OR REPLACE FUNCTION get_deptos_by_dependencia(p_id_dependencia integer)
RETURNS TABLE (
    cvedepto integer,
    nombredepto varchar,
    telefono varchar,
    cvedependencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvedepto, nombredepto, telefono, cvedependencia
    FROM deptos
    WHERE cvedependencia = p_id_dependencia
    ORDER BY nombredepto;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_deptos_by_dependencia(integer) IS 'Departamentos por dependencia para consultausuariosfrm';

-- SP 3/8: consulta_usuario_por_usuario
-- Descripción: Consulta por nombre de usuario exacto
-- ============================================
CREATE OR REPLACE FUNCTION consulta_usuario_por_usuario(p_usuario varchar)
RETURNS TABLE (
    descripcion varchar,
    nombredepto varchar,
    telefono varchar,
    usuario varchar,
    nombres varchar,
    fecalt date,
    fecbaj date,
    feccap date,
    capturo varchar
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
        u.capturo
    FROM usuarios u
    INNER JOIN deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE u.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION consulta_usuario_por_usuario(varchar) IS 'Búsqueda exacta por usuario para consultausuariosfrm';

-- SP 4/8: consulta_usuario_por_nombre
-- Descripción: Consulta por nombre con MATCHES (prefijo)
-- ============================================
CREATE OR REPLACE FUNCTION consulta_usuario_por_nombre(p_nombre varchar)
RETURNS TABLE (
    descripcion varchar,
    nombredepto varchar,
    telefono varchar,
    usuario varchar,
    nombres varchar,
    fecalt date,
    fecbaj date,
    feccap date,
    capturo varchar
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
        u.capturo
    FROM usuarios u
    INNER JOIN deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE UPPER(u.nombres) LIKE UPPER(p_nombre || '%')
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION consulta_usuario_por_nombre(varchar) IS 'Búsqueda por prefijo de nombre para consultausuariosfrm';

-- SP 5/8: consulta_usuario_por_depto
-- Descripción: Consulta por dependencia y departamento
-- ============================================
CREATE OR REPLACE FUNCTION consulta_usuario_por_depto(p_id_dependencia integer, p_cvedepto integer)
RETURNS TABLE (
    descripcion varchar,
    nombredepto varchar,
    telefono varchar,
    usuario varchar,
    nombres varchar,
    fecalt date,
    fecbaj date,
    feccap date,
    capturo varchar
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
        u.capturo
    FROM usuarios u
    INNER JOIN deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE d.cvedependencia = p_id_dependencia
      AND d.cvedepto = p_cvedepto
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION consulta_usuario_por_depto(integer, integer) IS 'Búsqueda por departamento para consultausuariosfrm';

-- SP 6/9: get_all_usuarios
-- Descripción: Devuelve todos los usuarios activos
-- ============================================
CREATE OR REPLACE FUNCTION get_all_usuarios()
RETURNS TABLE (
    descripcion varchar,
    nombredepto varchar,
    telefono varchar,
    usuario varchar,
    nombres varchar,
    fecalt date,
    fecbaj date,
    feccap date,
    capturo varchar
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
        u.capturo
    FROM usuarios u
    INNER JOIN deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN c_dependencias c ON c.id_dependencia = d.cvedependencia
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_all_usuarios() IS 'Obtiene todos los usuarios del sistema para consultausuariosfrm';

-- ============================================
-- SECCIÓN 2: SPs CRUD
-- ============================================

-- SP 7/9: crear_usuario
-- Descripción: Crea un nuevo usuario en el sistema
-- ============================================
CREATE OR REPLACE FUNCTION crear_usuario(
    p_usuario varchar,
    p_nombres varchar,
    p_clave varchar,
    p_cvedepto integer,
    p_nivel integer,
    p_capturo varchar
)
RETURNS TABLE (
    success boolean,
    message varchar,
    usuario_creado varchar
) AS $$
BEGIN
    -- Verificar si el usuario ya existe
    IF EXISTS (SELECT 1 FROM usuarios WHERE usuario = p_usuario) THEN
        RETURN QUERY SELECT false, 'El usuario ya existe'::varchar, null::varchar;
        RETURN;
    END IF;

    -- Verificar que el departamento exista
    IF NOT EXISTS (SELECT 1 FROM deptos WHERE cvedepto = p_cvedepto) THEN
        RETURN QUERY SELECT false, 'El departamento no existe'::varchar, null::varchar;
        RETURN;
    END IF;

    -- Insertar usuario
    INSERT INTO usuarios (
        usuario,
        nombres,
        clave,
        cvedepto,
        nivel,
        fecalt,
        feccap,
        capturo,
        activo
    ) VALUES (
        LOWER(p_usuario),
        UPPER(p_nombres),
        p_clave,
        p_cvedepto,
        COALESCE(p_nivel, 1),
        CURRENT_DATE,
        CURRENT_DATE,
        p_capturo,
        true
    );

    RETURN QUERY SELECT true, 'Usuario creado exitosamente'::varchar, LOWER(p_usuario);

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error al crear usuario: ' || SQLERRM)::varchar, null::varchar;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION crear_usuario(varchar, varchar, varchar, integer, integer, varchar) IS 'Crea un nuevo usuario en consultausuariosfrm';

-- SP 8/9: actualizar_usuario
-- Descripción: Actualiza los datos de un usuario existente
-- ============================================
CREATE OR REPLACE FUNCTION actualizar_usuario(
    p_usuario varchar,
    p_nombres varchar,
    p_clave varchar,
    p_cvedepto integer,
    p_nivel integer,
    p_capturo varchar
)
RETURNS TABLE (
    success boolean,
    message varchar
) AS $$
BEGIN
    -- Verificar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario = p_usuario) THEN
        RETURN QUERY SELECT false, 'El usuario no existe'::varchar;
        RETURN;
    END IF;

    -- Verificar que el departamento exista
    IF NOT EXISTS (SELECT 1 FROM deptos WHERE cvedepto = p_cvedepto) THEN
        RETURN QUERY SELECT false, 'El departamento no existe'::varchar;
        RETURN;
    END IF;

    -- Actualizar usuario
    UPDATE usuarios
    SET
        nombres = UPPER(p_nombres),
        clave = CASE
            WHEN p_clave IS NOT NULL AND p_clave != '' THEN p_clave
            ELSE clave
        END,
        cvedepto = p_cvedepto,
        nivel = COALESCE(p_nivel, nivel),
        feccap = CURRENT_DATE,
        capturo = p_capturo
    WHERE usuario = p_usuario
      AND fecbaj IS NULL; -- Solo actualizar usuarios activos

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Usuario no encontrado o ya está dado de baja'::varchar;
        RETURN;
    END IF;

    RETURN QUERY SELECT true, 'Usuario actualizado exitosamente'::varchar;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error al actualizar usuario: ' || SQLERRM)::varchar;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION actualizar_usuario(varchar, varchar, varchar, integer, integer, varchar) IS 'Actualiza datos de usuario en consultausuariosfrm';

-- SP 9/9: dar_baja_usuario
-- Descripción: Marca un usuario como dado de baja (soft delete)
-- ============================================
CREATE OR REPLACE FUNCTION dar_baja_usuario(
    p_usuario varchar,
    p_capturo varchar
)
RETURNS TABLE (
    success boolean,
    message varchar
) AS $$
BEGIN
    -- Verificar si el usuario existe
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario = p_usuario) THEN
        RETURN QUERY SELECT false, 'El usuario no existe'::varchar;
        RETURN;
    END IF;

    -- Verificar si ya está dado de baja
    IF EXISTS (SELECT 1 FROM usuarios WHERE usuario = p_usuario AND fecbaj IS NOT NULL) THEN
        RETURN QUERY SELECT false, 'El usuario ya está dado de baja'::varchar;
        RETURN;
    END IF;

    -- Dar de baja (soft delete)
    UPDATE usuarios
    SET
        fecbaj = CURRENT_DATE,
        activo = false,
        feccap = CURRENT_DATE,
        capturo = p_capturo
    WHERE usuario = p_usuario;

    RETURN QUERY SELECT true, 'Usuario dado de baja exitosamente'::varchar;

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error al dar de baja usuario: ' || SQLERRM)::varchar;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION dar_baja_usuario(varchar, varchar) IS 'Da de baja un usuario (soft delete) en consultausuariosfrm';

-- ============================================
-- VERIFICACIÓN
-- ============================================
SELECT '✅ Verificando SPs creados en esquema public:' as status;

SELECT
    routine_schema as esquema,
    routine_name as nombre_sp,
    routine_type as tipo
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (
    routine_name = 'get_dependencias' OR
    routine_name = 'get_deptos_by_dependencia' OR
    routine_name = 'consulta_usuario_por_usuario' OR
    routine_name = 'consulta_usuario_por_nombre' OR
    routine_name = 'consulta_usuario_por_depto' OR
    routine_name = 'get_all_usuarios' OR
    routine_name = 'crear_usuario' OR
    routine_name = 'actualizar_usuario' OR
    routine_name = 'dar_baja_usuario'
  )
ORDER BY routine_name;

-- Test rápido (si hay datos)
SELECT '🧪 Test rápidos:' as status;

SELECT '1. get_dependencias:' as test, COUNT(*) as total FROM get_dependencias();
SELECT '2. get_deptos_by_dependencia(1):' as test, COUNT(*) as total FROM get_deptos_by_dependencia(1);

SELECT '✅ SCRIPT COMPLETADO EXITOSAMENTE' as resultado;
SELECT 'Los 9 SPs están listos en esquema public (6 consultas + 3 CRUD).' as mensaje;
