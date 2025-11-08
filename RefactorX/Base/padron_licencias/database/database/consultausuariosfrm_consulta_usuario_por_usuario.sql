-- Stored Procedure: consulta_usuario_por_usuario
-- Tipo: Report
-- Descripción: Consulta usuarios por campo usuario exacto.
-- Generado para formulario: consultausuariosfrm
-- Fecha: 2025-08-27 17:29:11

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