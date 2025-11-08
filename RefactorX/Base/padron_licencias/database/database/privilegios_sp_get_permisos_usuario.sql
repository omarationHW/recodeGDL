-- Stored Procedure: sp_get_permisos_usuario
-- Tipo: Catalog
-- Descripción: Obtiene los permisos actuales de un usuario.
-- Generado para formulario: privilegios
-- Fecha: 2025-08-27 18:54:11

CREATE OR REPLACE FUNCTION sp_get_permisos_usuario(
    p_usuario VARCHAR
)
RETURNS TABLE (
    num_tag INTEGER,
    descripcion VARCHAR,
    seleccionado VARCHAR,
    grupo SMALLINT,
    feccap DATE,
    capturista VARCHAR,
    usuario VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.num_tag, p.descripcion, p.seleccionado, p.grupo, p.feccap, p.capturista, a.usuario
    FROM c_programas p
    INNER JOIN autoriza a ON a.num_tag = p.num_tag AND a.usuario = p_usuario
    WHERE p.num_tag BETWEEN 8000 AND 8999;
END;
$$ LANGUAGE plpgsql;