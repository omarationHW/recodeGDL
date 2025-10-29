-- Stored Procedure: sp_consulta_usuario_por_nombre
-- Tipo: Report
-- Descripción: Consulta usuarios por coincidencia de nombre (LIKE).
-- Generado para formulario: consultausuariosfrm
-- Fecha: 2025-08-26 15:58:09

CREATE OR REPLACE FUNCTION sp_consulta_usuario_por_nombre(p_nombre VARCHAR)
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
    SELECT c.descripcion, d.nombredepto, d.telefono, u.usuario, u.nombres, u.fecalt, u.fecbaj, u.feccap, u.capturo
    FROM usuarios u
    JOIN deptos d ON d.cvedepto = u.cvedepto
    JOIN c_dependencias c ON c.id_dependencia = d.cvedependencia
    WHERE UPPER(u.nombres) LIKE UPPER(p_nombre || '%');
END;
$$ LANGUAGE plpgsql;