-- ============================================
-- Stored Procedure: sp_consulta_usuario_por_usuario
-- Base de Datos: padron_licencias
-- Esquema: comun
-- Descripción: Consulta usuarios por nombre de usuario exacto
-- Tablas: comun.usuarios, comun.deptos, comun.c_dependencias
-- Fecha: 2025-11-03
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_consulta_usuario_por_usuario(
    p_usuario VARCHAR
)
RETURNS TABLE (
    descripcion VARCHAR,
    nombredepto VARCHAR,
    telefono VARCHAR,
    usuario VARCHAR,
    nombres VARCHAR,
    fecalt DATE,
    fecbaj DATE,
    feccap DATE,
    capturo VARCHAR
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

-- Comentarios
COMMENT ON FUNCTION comun.sp_consulta_usuario_por_usuario(VARCHAR) IS 'Consulta usuarios por nombre de usuario exacto';
