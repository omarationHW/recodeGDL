-- Stored Procedure: sp_chgpass_validate_current
-- Tipo: CRUD
-- Descripción: Valida si la clave actual ingresada corresponde al usuario autenticado.
-- Generado para formulario: sfrm_chgpass
-- Fecha: 2025-08-27 14:54:13

CREATE OR REPLACE FUNCTION sp_chgpass_validate_current(p_user_id integer, p_current_password text)
RETURNS TABLE(is_valid boolean) AS $$
BEGIN
    RETURN QUERY
    SELECT (password = crypt(p_current_password, password)) AS is_valid
    FROM ta_12_passwords
    WHERE id_usuario = p_user_id AND estado = 'A';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;