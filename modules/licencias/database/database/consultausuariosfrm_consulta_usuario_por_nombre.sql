-- Stored Procedure: consulta_usuario_por_nombre
-- Tipo: Report
-- Descripción: Consulta usuarios por coincidencia de nombre (prefijo).
-- Generado para formulario: consultausuariosfrm
-- Fecha: 2025-08-27 17:29:11

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