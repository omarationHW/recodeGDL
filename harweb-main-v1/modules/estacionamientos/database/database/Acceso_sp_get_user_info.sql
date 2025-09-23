-- Stored Procedure: sp_get_user_info
-- Tipo: Catalog
-- Descripción: Obtiene información de usuario por ID.
-- Generado para formulario: Acceso
-- Fecha: 2025-08-27 13:19:38

CREATE OR REPLACE FUNCTION sp_get_user_info(p_user_id INT)
RETURNS TABLE(id_usuario INT, usuario TEXT, nombre TEXT, nivel INT, estado TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT id_usuario, usuario, nombre, nivel, estado
  FROM usuarios
  WHERE id_usuario = p_user_id;
END;
$$ LANGUAGE plpgsql;