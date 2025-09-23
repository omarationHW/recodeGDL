-- Stored Procedure: sp_validate_current_password
-- Tipo: CRUD
-- Descripción: Valida la clave actual del usuario (retorna true/false y mensaje)
-- Generado para formulario: sfrm_chgpass
-- Fecha: 2025-08-27 15:16:41

CREATE OR REPLACE FUNCTION sp_validate_current_password(p_user_id integer, p_current_password text)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_clave text;
BEGIN
    SELECT clave INTO v_clave FROM usuarios WHERE id_usuario = p_user_id;
    IF v_clave IS NULL THEN
        RETURN QUERY SELECT false, 'Usuario no encontrado';
        RETURN;
    END IF;
    IF crypt(p_current_password, v_clave) = v_clave THEN
        RETURN QUERY SELECT true, 'Clave actual válida';
    ELSE
        RETURN QUERY SELECT false, 'La clave actual no es correcta';
    END IF;
END;
$$ LANGUAGE plpgsql;