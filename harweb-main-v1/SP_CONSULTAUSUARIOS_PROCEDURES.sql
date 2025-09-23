-- ============================================
-- STORED PROCEDURES PARA CONSULTAUSUARIOSFRM
-- Base de datos: padron_licencias
-- Tabla: usuarios
-- ============================================

\c padron_licencias;
SET search_path TO public;

-- ============================================
-- SP_CONSULTAUSUARIOS_LIST
-- Consulta de usuarios con filtros y paginación
-- ============================================
CREATE OR REPLACE FUNCTION SP_CONSULTAUSUARIOS_LIST(
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 10,
    p_search TEXT DEFAULT ''
)
RETURNS TABLE(
    usuario VARCHAR,
    nombres VARCHAR,
    clave VARCHAR,
    cvedepto INTEGER,
    nivel INTEGER,
    fecalt DATE,
    fecbaj DATE,
    feccap DATE,
    capturo VARCHAR,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
    v_total BIGINT;
BEGIN
    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Obtener total de registros para paginación
    SELECT COUNT(*) INTO v_total
    FROM public.usuarios u
    WHERE (p_search = '' OR
           u.usuario ILIKE '%' || p_search || '%' OR
           u.nombres ILIKE '%' || p_search || '%' OR
           u.clave ILIKE '%' || p_search || '%' OR
           u.cvedepto::TEXT ILIKE '%' || p_search || '%');

    -- Retornar datos paginados
    RETURN QUERY
    SELECT
        u.usuario,
        u.nombres,
        u.clave,
        u.cvedepto,
        u.nivel,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo,
        v_total
    FROM public.usuarios u
    WHERE (p_search = '' OR
           u.usuario ILIKE '%' || p_search || '%' OR
           u.nombres ILIKE '%' || p_search || '%' OR
           u.clave ILIKE '%' || p_search || '%' OR
           u.cvedepto::TEXT ILIKE '%' || p_search || '%')
    ORDER BY u.nombres, u.usuario
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP_CONSULTAUSUARIOS_CREATE
-- Crear nuevo usuario
-- ============================================
CREATE OR REPLACE FUNCTION SP_CONSULTAUSUARIOS_CREATE(
    p_usuario VARCHAR,
    p_cvedepto INTEGER,
    p_nombres VARCHAR,
    p_clave VARCHAR,
    p_nivel INTEGER,
    p_capturo VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario_created VARCHAR
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si el usuario ya existe
    SELECT COUNT(*) INTO v_exists
    FROM public.usuarios
    WHERE usuario = p_usuario;

    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'El usuario ya existe', NULL::VARCHAR;
        RETURN;
    END IF;

    -- Insertar nuevo usuario
    BEGIN
        INSERT INTO public.usuarios (
            usuario,
            cvedepto,
            nombres,
            clave,
            nivel,
            fecalt,
            feccap,
            capturo
        ) VALUES (
            p_usuario,
            p_cvedepto,
            p_nombres,
            p_clave,
            p_nivel,
            CURRENT_DATE,
            CURRENT_TIMESTAMP,
            p_capturo
        );

        RETURN QUERY SELECT TRUE, 'Usuario creado exitosamente', p_usuario;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al crear usuario: ' || SQLERRM, NULL::VARCHAR;
    END;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP_CONSULTAUSUARIOS_UPDATE
-- Actualizar usuario existente
-- ============================================
CREATE OR REPLACE FUNCTION SP_CONSULTAUSUARIOS_UPDATE(
    p_usuario VARCHAR,
    p_cvedepto INTEGER,
    p_nombres VARCHAR,
    p_clave VARCHAR,
    p_nivel INTEGER,
    p_fecbaj DATE,
    p_capturo VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario_updated VARCHAR
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_exists
    FROM public.usuarios
    WHERE usuario = p_usuario;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El usuario no existe', NULL::VARCHAR;
        RETURN;
    END IF;

    -- Actualizar usuario
    BEGIN
        UPDATE public.usuarios SET
            cvedepto = p_cvedepto,
            nombres = p_nombres,
            clave = COALESCE(NULLIF(p_clave, ''), clave), -- Solo actualizar si no está vacío
            nivel = p_nivel,
            fecbaj = p_fecbaj,
            feccap = CURRENT_TIMESTAMP,
            capturo = p_capturo
        WHERE usuario = p_usuario;

        RETURN QUERY SELECT TRUE, 'Usuario actualizado exitosamente', p_usuario;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al actualizar usuario: ' || SQLERRM, NULL::VARCHAR;
    END;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP_CONSULTAUSUARIOS_DELETE (Baja lógica)
-- Dar de baja usuario (no eliminación física)
-- ============================================
CREATE OR REPLACE FUNCTION SP_CONSULTAUSUARIOS_DELETE(
    p_usuario VARCHAR,
    p_capturo VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    usuario_deleted VARCHAR
) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_exists
    FROM public.usuarios
    WHERE usuario = p_usuario;

    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'El usuario no existe', NULL::VARCHAR;
        RETURN;
    END IF;

    -- Dar de baja (baja lógica)
    BEGIN
        UPDATE public.usuarios SET
            fecbaj = CURRENT_DATE,
            feccap = CURRENT_TIMESTAMP,
            capturo = p_capturo
        WHERE usuario = p_usuario;

        RETURN QUERY SELECT TRUE, 'Usuario dado de baja exitosamente', p_usuario;

    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Error al dar de baja usuario: ' || SQLERRM, NULL::VARCHAR;
    END;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP_CONSULTAUSUARIOS_GET_BY_ID
-- Obtener detalles completos de un usuario
-- ============================================
CREATE OR REPLACE FUNCTION SP_CONSULTAUSUARIOS_GET_BY_ID(
    p_usuario VARCHAR
)
RETURNS TABLE(
    usuario VARCHAR,
    nombres VARCHAR,
    clave VARCHAR,
    cvedepto INTEGER,
    nivel INTEGER,
    fecalt DATE,
    fecbaj DATE,
    feccap DATE,
    capturo VARCHAR,
    nombredepto VARCHAR,
    descripcion_dependencia VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.usuario,
        u.nombres,
        u.clave,
        u.cvedepto,
        u.nivel,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo,
        COALESCE(d.nombredepto, 'N/A') as nombredepto,
        COALESCE(dep.descripcion, 'N/A') as descripcion_dependencia
    FROM public.usuarios u
    LEFT JOIN public.deptos d ON d.cvedepto = u.cvedepto
    LEFT JOIN public.c_dependencias dep ON dep.id_dependencia = d.cvedependencia
    WHERE u.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Comentarios de uso:
--
-- Para listar usuarios:
-- SELECT * FROM SP_CONSULTAUSUARIOS_LIST(1, 10, 'juan');
--
-- Para crear usuario:
-- SELECT * FROM SP_CONSULTAUSUARIOS_CREATE('NUEVO01', 1, 'Juan Pérez', 'clave123', 5, 'admin');
--
-- Para actualizar usuario:
-- SELECT * FROM SP_CONSULTAUSUARIOS_UPDATE('NUEVO01', 1, 'Juan Carlos Pérez', '', 9, NULL, 'admin');
--
-- Para dar de baja:
-- SELECT * FROM SP_CONSULTAUSUARIOS_DELETE('NUEVO01', 'admin');
--
-- Para obtener detalles:
-- SELECT * FROM SP_CONSULTAUSUARIOS_GET_BY_ID('NUEVO01');
-- ============================================