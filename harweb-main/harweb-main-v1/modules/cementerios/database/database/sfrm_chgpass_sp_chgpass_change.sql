-- Stored Procedure: sp_chgpass_change
-- Tipo: CRUD
-- Descripción: Cambia la clave del usuario autenticado, validando reglas de seguridad.
-- Generado para formulario: sfrm_chgpass
-- Fecha: 2025-08-27 14:54:13

CREATE OR REPLACE FUNCTION sp_chgpass_change(
    p_user_id integer,
    p_current_password text,
    p_new_password text,
    p_confirm_password text
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_user_record RECORD;
    v_valid boolean;
BEGIN
    -- Validar clave actual
    SELECT * INTO v_user_record FROM ta_12_passwords WHERE id_usuario = p_user_id AND estado = 'A';
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Usuario no encontrado o inactivo.';
        RETURN;
    END IF;
    v_valid := (v_user_record.password = crypt(p_current_password, v_user_record.password));
    IF NOT v_valid THEN
        RETURN QUERY SELECT false, 'La clave actual no es correcta.';
        RETURN;
    END IF;
    -- Validaciones de nueva clave
    IF p_new_password IS NULL OR length(p_new_password) < 6 THEN
        RETURN QUERY SELECT false, 'La clave debe ser mayor a 5 dígitos.';
        RETURN;
    END IF;
    IF p_new_password = p_current_password THEN
        RETURN QUERY SELECT false, 'La clave nueva no debe ser igual a la actual.';
        RETURN;
    END IF;
    IF substring(p_new_password, 1, 3) = substring(p_current_password, 1, 3) THEN
        RETURN QUERY SELECT false, 'Los tres primeros caracteres deben ser diferentes al actual.';
        RETURN;
    END IF;
    IF p_new_password <> p_confirm_password THEN
        RETURN QUERY SELECT false, 'La confirmación de la clave no es igual.';
        RETURN;
    END IF;
    IF p_new_password !~ '[a-z]' OR p_new_password !~ '[0-9]' THEN
        RETURN QUERY SELECT false, 'La clave debe contener números y letras.';
        RETURN;
    END IF;
    -- Actualizar clave
    UPDATE ta_12_passwords
    SET password = crypt(p_new_password, gen_salt('bf')),
        fecha_mov = now()
    WHERE id_usuario = p_user_id;
    RETURN QUERY SELECT true, 'Clave cambiada satisfactoriamente.';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;