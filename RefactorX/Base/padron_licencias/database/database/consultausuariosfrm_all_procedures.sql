-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: consultausuariosfrm
-- Generado: 2025-08-27 17:29:11
-- Total SPs: 5
-- ============================================

-- SP 1/5: get_dependencias
-- Tipo: Catalog
-- Descripción: Devuelve todas las dependencias ordenadas por descripción.
-- --------------------------------------------

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

-- ============================================

-- SP 2/5: get_deptos_by_dependencia
-- Tipo: Catalog
-- Descripción: Devuelve los departamentos de una dependencia específica.
-- --------------------------------------------

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

-- ============================================

-- SP 3/5: consulta_usuario_por_usuario
-- Tipo: Report
-- Descripción: Consulta usuarios por campo usuario exacto.
-- --------------------------------------------

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
    SELECT c.descripcion, d.nombredepto, d.telefono, u.usuario, u.nombres, u.fecalt, u.fecbaj, u.feccap, u.capturo
    FROM usuarios u
    JOIN deptos d ON d.cvedepto = u.cvedepto
    JOIN c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE u.usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: consulta_usuario_por_nombre
-- Tipo: Report
-- Descripción: Consulta usuarios por coincidencia de nombre (prefijo).
-- --------------------------------------------

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
    SELECT c.descripcion, d.nombredepto, d.telefono, u.usuario, u.nombres, u.fecalt, u.fecbaj, u.feccap, u.capturo
    FROM usuarios u
    JOIN deptos d ON d.cvedepto = u.cvedepto
    JOIN c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE u.nombres ILIKE p_nombre || '%';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: consulta_usuario_por_depto
-- Tipo: Report
-- Descripción: Consulta usuarios por dependencia y departamento.
-- --------------------------------------------

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
    SELECT c.descripcion, d.nombredepto, d.telefono, u.usuario, u.nombres, u.fecalt, u.fecbaj, u.feccap, u.capturo
    FROM usuarios u
    JOIN deptos d ON d.cvedepto = u.cvedepto
    JOIN c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE d.cvedependencia = p_id_dependencia AND d.cvedepto = p_cvedepto;
END;
$$ LANGUAGE plpgsql;

-- ============================================

