-- Stored Procedure: sp_menu_get_user_info
-- Tipo: Catalog
-- Descripción: Devuelve información detallada del usuario.
-- Generado para formulario: Menu
-- Fecha: 2025-08-28 13:23:04

CREATE OR REPLACE FUNCTION sp_menu_get_user_info(p_usuario TEXT)
RETURNS TABLE(id_usuario INT, usuario TEXT, nombre TEXT, estado TEXT, id_rec SMALLINT, nivel SMALLINT) AS $$
BEGIN
  RETURN QUERY
    SELECT id_usuario, usuario, nombre, estado, id_rec, nivel
    FROM ta_12_passwords
    WHERE usuario = p_usuario;
END;
$$ LANGUAGE plpgsql;