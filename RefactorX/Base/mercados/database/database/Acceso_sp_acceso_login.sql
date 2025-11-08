-- Stored Procedure: sp_acceso_login
-- Tipo: CRUD
-- Descripción: Valida usuario y contraseña, retorna datos de usuario si es correcto.
-- Generado para formulario: Acceso
-- Fecha: 2025-08-26 20:45:12

CREATE OR REPLACE FUNCTION sp_acceso_login(p_usuario TEXT, p_contrasena TEXT, p_ejercicio INTEGER)
RETURNS TABLE(success BOOLEAN, usuario TEXT, id_usuario INTEGER, nivel INTEGER, message TEXT) AS $$
DECLARE
  v_usuario RECORD;
BEGIN
  SELECT id_usuario, usuario, nivel
    INTO v_usuario
    FROM ta_12_passwords
   WHERE usuario = p_usuario AND clave = p_contrasena AND estado = 'A';
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, v_usuario.usuario, v_usuario.id_usuario, v_usuario.nivel, NULL;
  ELSE
    RETURN QUERY SELECT FALSE, NULL, NULL, NULL, 'Usuario y/o contraseña incorrectos';
  END IF;
END;
$$ LANGUAGE plpgsql;