-- Stored Procedure: privilegios_get_permisos_usuario
-- Tipo: Catalog
-- Descripción: Obtiene los permisos actuales de un usuario
-- Generado para formulario: privilegios
-- Fecha: 2025-08-26 17:28:26

CREATE OR REPLACE FUNCTION privilegios_get_permisos_usuario(p_usuario TEXT)
RETURNS TABLE(num_tag INTEGER, descripcion TEXT, seleccionado TEXT, grupo SMALLINT, feccap DATE, capturista TEXT, usuario TEXT, num_tag_1 INTEGER) AS $$
BEGIN
  RETURN QUERY
  SELECT p.num_tag, p.descripcion, p.seleccionado, p.grupo, p.feccap, p.capturista, a.usuario, a.num_tag
  FROM c_programas p
  INNER JOIN autoriza a ON a.num_tag = p.num_tag AND a.usuario = p_usuario
  WHERE p.num_tag BETWEEN 8000 AND 8999;
END;
$$ LANGUAGE plpgsql;