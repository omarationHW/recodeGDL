-- Stored Procedure: sp_consulta_usuario_por_dependencia_depto
-- Tipo: Report
-- Descripción: Consulta usuarios por dependencia y departamento.
-- Generado para formulario: consultausuariosfrm
-- Fecha: 2025-08-26 15:58:09

CREATE OR REPLACE FUNCTION sp_consulta_usuario_por_dependencia_depto(p_id_dependencia INTEGER, p_cvedepto INTEGER)
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
    WHERE d.cvedependencia = p_id_dependencia AND u.cvedepto = p_cvedepto;
END;
$$ LANGUAGE plpgsql;