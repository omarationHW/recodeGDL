-- ============================================
-- FIX: Agregar campo cvedependencia a los SPs
-- Base: padron_licencias
-- Esquema: comun
-- Fecha: 2025-11-04
-- PROBLEMA: Falta cvedependencia para modal de editar
-- SOLUCIÓN: Agregar cvedependencia a todos los SPs de consulta
-- ============================================

\c padron_licencias;
SET search_path TO comun;

-- ============================================
-- RECREAR FUNCIONES CON CVEDEPENDENCIA
-- ============================================

-- SP 3/9: consulta_usuario_por_usuario
DROP FUNCTION IF EXISTS comun.consulta_usuario_por_usuario(varchar);
CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_usuario(p_usuario varchar)
RETURNS TABLE (
    descripcion character(50),
    nombredepto character(30),
    telefono character(35),
    usuario character(8),
    nombres character(30),
    cvedepto integer,
    cvedependencia integer,
    nivel smallint,
    fecalt date,
    fecbaj date,
    feccap date,
    capturo character(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.usuario)
        c.descripcion,
        d.nombredepto,
        d.telefono,
        u.usuario,
        u.nombres,
        u.cvedepto,
        d.cvedependencia,
        u.nivel,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo
    FROM comun.usuarios u
    INNER JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE TRIM(u.usuario) = TRIM(p_usuario)
    ORDER BY u.usuario, u.fecalt DESC;
END;
$$ LANGUAGE plpgsql;

-- SP 4/9: consulta_usuario_por_nombre
DROP FUNCTION IF EXISTS comun.consulta_usuario_por_nombre(varchar);
CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_nombre(p_nombre varchar)
RETURNS TABLE (
    descripcion character(50),
    nombredepto character(30),
    telefono character(35),
    usuario character(8),
    nombres character(30),
    cvedepto integer,
    cvedependencia integer,
    nivel smallint,
    fecalt date,
    fecbaj date,
    feccap date,
    capturo character(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.usuario)
        c.descripcion,
        d.nombredepto,
        d.telefono,
        u.usuario,
        u.nombres,
        u.cvedepto,
        d.cvedependencia,
        u.nivel,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo
    FROM comun.usuarios u
    INNER JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE UPPER(TRIM(u.nombres)) LIKE UPPER(TRIM(p_nombre) || '%')
    ORDER BY u.usuario, u.nombres;
END;
$$ LANGUAGE plpgsql;

-- SP 5/9: consulta_usuario_por_depto
DROP FUNCTION IF EXISTS comun.consulta_usuario_por_depto(integer, integer);
CREATE OR REPLACE FUNCTION comun.consulta_usuario_por_depto(p_id_dependencia integer, p_cvedepto integer)
RETURNS TABLE (
    descripcion character(50),
    nombredepto character(30),
    telefono character(35),
    usuario character(8),
    nombres character(30),
    cvedepto integer,
    cvedependencia integer,
    nivel smallint,
    fecalt date,
    fecbaj date,
    feccap date,
    capturo character(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.usuario)
        c.descripcion,
        d.nombredepto,
        d.telefono,
        u.usuario,
        u.nombres,
        u.cvedepto,
        d.cvedependencia,
        u.nivel,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo
    FROM comun.usuarios u
    INNER JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE d.cvedependencia = p_id_dependencia
      AND d.cvedepto = p_cvedepto
    ORDER BY u.usuario, u.nombres;
END;
$$ LANGUAGE plpgsql;

-- SP 6/9: get_all_usuarios
DROP FUNCTION IF EXISTS comun.get_all_usuarios();
CREATE OR REPLACE FUNCTION comun.get_all_usuarios()
RETURNS TABLE (
    descripcion character(50),
    nombredepto character(30),
    telefono character(35),
    usuario character(8),
    nombres character(30),
    cvedepto integer,
    cvedependencia integer,
    nivel smallint,
    fecalt date,
    fecbaj date,
    feccap date,
    capturo character(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ON (u.usuario)
        c.descripcion,
        d.nombredepto,
        d.telefono,
        u.usuario,
        u.nombres,
        u.cvedepto,
        d.cvedependencia,
        u.nivel,
        u.fecalt,
        u.fecbaj,
        u.feccap,
        u.capturo
    FROM comun.usuarios u
    INNER JOIN comun.deptos d ON d.cvedepto = u.cvedepto
    INNER JOIN comun.c_dependencias c ON c.id_dependencia = d.cvedependencia
    ORDER BY u.usuario, u.nombres;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VERIFICACION FINAL
-- ============================================

SELECT '✅ Script completado - campo cvedependencia agregado' as status;

SELECT
    usuario,
    nombres,
    cvedepto,
    cvedependencia,
    nivel
FROM comun.get_all_usuarios()
LIMIT 5;
