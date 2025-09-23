-- Stored Procedure: sp_validate_user_password
-- Tipo: CRUD
-- Descripción: Valida si la contraseña actual es correcta para el usuario dado.
-- Generado para formulario: sfrm_chgpass
-- Fecha: 2025-08-27 19:35:30

CREATE OR REPLACE FUNCTION sp_validate_user_password(p_username TEXT, p_password TEXT)
RETURNS TABLE(is_valid BOOLEAN) AS $$
BEGIN
  RETURN QUERY
    SELECT (u.password_hash = crypt(p_password, u.password_hash)) AS is_valid
    FROM users u WHERE u.username = p_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;