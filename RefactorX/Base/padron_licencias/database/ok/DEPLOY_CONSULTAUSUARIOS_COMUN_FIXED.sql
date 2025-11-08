-- ============================================
-- STORED PROCEDURES - consultausuariosfrm (CRUD COMPLETO)
-- Base: padron_licencias
-- Esquema: comun
-- Fecha: 2025-11-04
-- CORRECCION: Tipos de datos exactos (character en lugar de varchar)
-- ============================================

\c padron_licencias;
SET search_path TO comun;

-- SP 1/9: get_dependencias
CREATE OR REPLACE FUNCTION comun.get_dependencias()
RETURNS TABLE (
    id_dependencia integer,
    descripcion character(50),
    abrevia character(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_dependencia, descripcion, abrevia
    FROM comun.c_dependencias
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- SP 2/9: get_deptos_by_dependencia
CREATE OR REPLACE FUNCTION comun.get_deptos_by_dependencia(p_id_dependencia integer)
RETURNS TABLE (
    cvedepto integer,
    nombredepto character(30),
    telefono character(35),
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
    descripcion character(50),
    nombredepto character(30),
    telefono character(35),
    usuario character(8),
    nombres character(30),
    fecalt date,
    fecbaj date,
    feccap date,
    capturo character(10)
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
    WHERE TRIM(u.usuario) = TRIM(p_usuario);
END;
$$ LANGUAGE plpgsql;

-- SP 4/9: consulta_usuario_por_nombre
CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_nombre(p_nombre varchar)
RETURNS TABLE (
    descripcion character(50),
    nombredepto character(30),
    telefono character(35),
    usuario character(8),
    nombres character(30),
    fecalt date,
    fecbaj date,
    feccap date,
    capturo character(10)
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
    WHERE UPPER(TRIM(u.nombres)) LIKE UPPER(TRIM(p_nombre) || '%')
    ORDER BY u.nombres;
END;
$$ LANGUAGE plpgsql;

-- SP 5/9: consulta_usuario_por_depto
CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_depto(p_id_dependencia integer, p_cvedepto integer)
RETURNS TABLE (
    descripcion character(50),
    nombredepto character(30),
    telefono character(35),
    usuario character(8),
    nombres character(30),
    fecalt date,
    fecbaj date,
    feccap date,
    capturo character(10)
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
    descripcion character(50),
    nombredepto character(30),
    telefono character(35),
    usuario character(8),
    nombres character(30),
    fecalt date,
    fecbaj date,
    feccap date,
    capturo character(10)
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
    IF EXISTS (SELECT 1 FROM comun.usuarios WHERE TRIM(usuario) = TRIM(p_usuario)) THEN
        RETURN QUERY SELECT false, 'El usuario ya existe'::varchar, null::varchar;
        RETURN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM comun.deptos WHERE cvedepto = p_cvedepto) THEN
        RETURN QUERY SELECT false, 'El departamento no existe'::varchar, null::varchar;
        RETURN;
    END IF;

    INSERT INTO comun.usuarios (
        usuario, nombres, clave, cvedepto, nivel, fecalt, feccap, capturo
    ) VALUES (
        LOWER(p_usuario), UPPER(p_nombres), p_clave, p_cvedepto,
        COALESCE(p_nivel, 1), CURRENT_DATE, CURRENT_DATE, p_capturo
    );

    RETURN QUERY SELECT true, 'Usuario creado exitosamente'::varchar, LOWER(p_usuario)::varchar;
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
    IF NOT EXISTS (SELECT 1 FROM comun.usuarios WHERE TRIM(usuario) = TRIM(p_usuario)) THEN
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
    WHERE TRIM(usuario) = TRIM(p_usuario) AND fecbaj IS NULL;

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
    IF NOT EXISTS (SELECT 1 FROM comun.usuarios WHERE TRIM(usuario) = TRIM(p_usuario)) THEN
        RETURN QUERY SELECT false, 'El usuario no existe'::varchar;
        RETURN;
    END IF;

    IF EXISTS (SELECT 1 FROM comun.usuarios WHERE TRIM(usuario) = TRIM(p_usuario) AND fecbaj IS NOT NULL) THEN
        RETURN QUERY SELECT false, 'El usuario ya está dado de baja'::varchar;
        RETURN;
    END IF;

    UPDATE comun.usuarios
    SET fecbaj = CURRENT_DATE, feccap = CURRENT_DATE, capturo = p_capturo
    WHERE TRIM(usuario) = TRIM(p_usuario);

    RETURN QUERY SELECT true, 'Usuario dado de baja exitosamente'::varchar;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, ('Error: ' || SQLERRM)::varchar;
END;
$$ LANGUAGE plpgsql;

SELECT '✅ Script completado - 9 SPs en esquema comun (TIPOS CORREGIDOS)' as status;
