-- Stored Procedure: sp_menu_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna información de usuario si es correcto.
-- Generado para formulario: Menu
-- Fecha: 2025-08-28 13:23:04

CREATE OR REPLACE FUNCTION sp_menu_login(p_usuario TEXT, p_password TEXT)
RETURNS TABLE(status TEXT, id_usuario INT, usuario TEXT, nombre TEXT, estado TEXT, id_rec SMALLINT, nivel SMALLINT, message TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT 
      CASE WHEN t.usuario IS NOT NULL THEN 'ok' ELSE 'error' END AS status,
      t.id_usuario, t.usuario, t.nombre, t.estado, t.id_rec, t.nivel,
      CASE WHEN t.usuario IS NOT NULL THEN NULL ELSE 'Usuario o clave incorrecta' END AS message
    FROM ta_12_passwords t
    WHERE t.usuario = p_usuario AND t.password = p_password;
END;
$$ LANGUAGE plpgsql;