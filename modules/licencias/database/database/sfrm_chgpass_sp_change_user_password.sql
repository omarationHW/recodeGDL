-- Stored Procedure: sp_change_user_password
-- Tipo: CRUD
-- Descripción: Cambia la contraseña del usuario si la actual es válida y cumple las reglas de negocio.
-- Generado para formulario: sfrm_chgpass
-- Fecha: 2025-08-27 19:35:30

CREATE OR REPLACE FUNCTION sp_change_user_password(p_username TEXT, p_current_password TEXT, p_new_password TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_user RECORD;
BEGIN
  SELECT * INTO v_user FROM users WHERE username = p_username;
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, 'Usuario no encontrado';
    RETURN;
  END IF;
  IF v_user.password_hash <> crypt(p_current_password, v_user.password_hash) THEN
    RETURN QUERY SELECT FALSE, 'La clave actual no es correcta';
    RETURN;
  END IF;
  IF p_current_password = p_new_password THEN
    RETURN QUERY SELECT FALSE, 'La nueva clave no debe ser igual a la actual';
    RETURN;
  END IF;
  IF substring(p_current_password from 1 for 3) = substring(p_new_password from 1 for 3) THEN
    RETURN QUERY SELECT FALSE, 'Los tres primeros caracteres deben ser diferentes a la clave actual';
    RETURN;
  END IF;
  IF NOT (p_new_password ~ '^(?=.*[a-z])(?=.*[0-9])[a-z0-9]{6,8}$') THEN
    RETURN QUERY SELECT FALSE, 'La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres';
    RETURN;
  END IF;
  UPDATE users SET password_hash = crypt(p_new_password, gen_salt('bf')) WHERE username = p_username;
  RETURN QUERY SELECT TRUE, 'Clave cambiada exitosamente';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;