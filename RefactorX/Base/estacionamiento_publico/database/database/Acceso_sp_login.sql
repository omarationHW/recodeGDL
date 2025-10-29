-- Stored Procedure: sp_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos del usuario si es correcto.
-- Generado para formulario: Acceso
-- Fecha: 2025-08-27 13:19:38

CREATE OR REPLACE FUNCTION sp_login(p_username TEXT, p_password TEXT)
RETURNS TABLE(success BOOLEAN, user_id INT, username TEXT, nombre TEXT, nivel INT, error TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT TRUE, id_usuario, usuario, nombre, nivel, NULL
  FROM usuarios
  WHERE usuario = p_username AND contrasena = crypt(p_password, contrasena) AND estado = 'A'
  LIMIT 1;
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, NULL, NULL, NULL, NULL, 'Usuario o contraseña incorrectos';
  END IF;
END;
$$ LANGUAGE plpgsql;