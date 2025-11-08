-- ============================================
-- STORED PROCEDURES - consultausuariosfrm (CRUD COMPLETO)
-- Base: padron_licencias
-- Esquema: comun
-- Fecha: 2025-11-04
-- ============================================

\c padron_licencias;
SET search_path TO comun;

-- SP 1/9: get_dependencias
CREATE OR REPLACE FUNCTION comun.get_dependencias()
RETURNS TABLE (
    id_dependencia integer,
    descripcion varchar,
    clave varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_dependencia, descripcion, clave
    FROM comun.c_dependencias
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- SP 2/9: get_deptos_by_dependencia
CREATE OR REPLACE FUNCTION comun.get_deptos_by_dependencia(p_id_dependencia integer)
RETURNS TABLE (
    cvedepto integer,
    nombredepto varchar,
    telefono varchar,
    cvedependencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvedepto, nombredepto, telefono, cvedependencia
    FROM comun.deptos
    WHERE cvedependencia = p_id_dependencia
    ORDER BY nombredepto;
END;
$$ LANGUAGE plpgsql;

-- SP 3/9: consulta_usuario_por_usuario
CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_usuario(p_usuario varchar)
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
    FROM comun.usuarios u
    INNER JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE u.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- SP 4/9: consulta_usuario_por_nombre
CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_nombre(p_nombre varchar)
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
    FROM comun.usuarios u
    INNER JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE UPPER(u.nombres) LIKE UPPER(p_nombre || '%')
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

-- SP 5/9: consulta_usuario_por_depto
CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_depto(p_id_dependencia integer, p_cvedepto integer)
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
    FROM comun.usuarios u
    INNER JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE d.cvedependencia = p_id_dependencia
      AND d.cvedepto = p_cvedepto
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

-- SP 6/9: get_all_usuarios
CREATE OR REPLACE FUNCTION comun.get_all_usuarios()
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
    FROM comun.usuarios u
    INNER JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

-- SP 7/9: crear_usuario
CREATE OR REPLACE FUNCTION comun.crear_usuario(
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
    IF EXISTS (SELECT 1 FROM comun.usuarios WHERE usuario = p_usuario) THEN
        RETURN QUERY SELECT false, 'El usuario ya existe'::varchar, null::varchar;
        RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM comun.deptos WHERE cvedepto = p_cvedepto) THEN
        RETURN QUERY SELECT false, 'El departamento no existe'::varchar, null::varchar;
        RETURN;
    END IF;

    INSERT INTO comun.usuarios (
        usuario, nombres, clave, cvedepto, nivel, fecalt, feccap, capturo, activo
    ) VALUES (
        LOWER(p_usuario), UPPER(p_nombres), p_clave, p_cvedepto,
        COALESCE(p_nivel, 1), CURRENT_DATE, CURRENT_DATE, p_capturo, true
    );

    RETURN QUERY SELECT true, 'Usuario creado exitosamente'::varchar, LOWER(p_usuario);
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error: ' || SQLERRM)::varchar, null::varchar;
END;
$$ LANGUAGE plpgsql;

-- SP 8/9: actualizar_usuario
CREATE OR REPLACE FUNCTION comun.actualizar_usuario(
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
    IF NOT EXISTS (SELECT 1 FROM comun.usuarios WHERE usuario = p_usuario) THEN
        RETURN QUERY SELECT false, 'El usuario no existe'::varchar;
        RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM comun.deptos WHERE cvedepto = p_cvedepto) THEN
        RETURN QUERY SELECT false, 'El departamento no existe'::varchar;
        RETURN;
    END IF;

    UPDATE comun.usuarios
    SET
        nombres = UPPER(p_nombres),
        clave = CASE WHEN p_clave IS NOT NULL AND p_clave != '' THEN p_clave ELSE clave END,
        cvedepto = p_cvedepto,
        nivel = COALESCE(p_nivel, nivel),
        feccap = CURRENT_DATE,
        capturo = p_capturo
    WHERE usuario = p_usuario AND fecbaj IS NULL;

    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Usuario no encontrado o dado de baja'::varchar;
        RETURN;
    END IF;

    RETURN QUERY SELECT true, 'Usuario actualizado exitosamente'::varchar;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error: ' || SQLERRM)::varchar;
END;
$$ LANGUAGE plpgsql;

-- SP 9/9: dar_baja_usuario
CREATE OR REPLACE FUNCTION comun.dar_baja_usuario(
    p_usuario varchar,
    p_capturo varchar
)
RETURNS TABLE (
    success boolean,
    message varchar
) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM comun.usuarios WHERE usuario = p_usuario) THEN
        RETURN QUERY SELECT false, 'El usuario no existe'::varchar;
        RETURN;
    END IF;

    IF EXISTS (SELECT 1 FROM comun.usuarios WHERE usuario = p_usuario AND fecbaj IS NOT NULL) THEN
        RETURN QUERY SELECT false, 'El usuario ya está dado de baja'::varchar;
        RETURN;
    END IF;

    UPDATE comun.usuarios
    SET fecbaj = CURRENT_DATE, activo = false, feccap = CURRENT_DATE, capturo = p_capturo
    WHERE usuario = p_usuario;

    RETURN QUERY SELECT true, 'Usuario dado de baja exitosamente'::varchar;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error: ' || SQLERRM)::varchar;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Script completado - 9 SPs en esquema comun' as status;
