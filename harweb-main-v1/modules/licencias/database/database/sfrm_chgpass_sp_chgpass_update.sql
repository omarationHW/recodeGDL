-- Stored Procedure: sp_chgpass_update
-- Tipo: CRUD
-- Descripción: Actualiza la clave del usuario si la clave actual es válida y cumple las reglas de negocio.
-- Generado para formulario: sfrm_chgpass
-- Fecha: 2025-08-26 18:09:13

CREATE OR REPLACE FUNCTION sp_chgpass_update(
    p_user_id INT,
    p_current_password TEXT,
    p_new_password TEXT,
    p_confirm_password TEXT
) RETURNS TEXT AS $$
DECLARE
    v_hash TEXT;
    v_new_hash TEXT;
    v_user RECORD;
BEGIN
    SELECT * INTO v_user FROM users WHERE id = p_user_id;
    IF NOT FOUND THEN
        RETURN 'Usuario no encontrado';
    END IF;
    v_hash := v_user.password;
    IF crypt(p_current_password, v_hash) <> v_hash THEN
        RETURN 'La clave actual no es correcta';
    END IF;
    IF p_new_password <> p_confirm_password THEN
        RETURN 'La nueva clave no es igual a la confirmación';
    END IF;
    IF p_current_password = p_new_password THEN
        RETURN 'La clave nueva no debe ser igual a la actual';
    END IF;
    IF substring(p_current_password from 1 for 3) = substring(p_new_password from 1 for 3) THEN
        RETURN 'Los tres primeros caracteres deben ser diferentes a la clave actual';
    END IF;
    IF length(p_new_password) < 2 OR length(p_new_password) > 8 THEN
        RETURN 'La clave nueva debe tener entre 2 y 8 caracteres';
    END IF;
    IF p_new_password !~ '[a-zA-Z]' OR p_new_password !~ '[0-9]' THEN
        RETURN 'La clave debe contener letras y números';
    END IF;
    v_new_hash := crypt(p_new_password, gen_salt('bf'));
    UPDATE users SET password = v_new_hash, updated_at = now() WHERE id = p_user_id;
    PERFORM sp_bitacora_chgpass(p_user_id, now(), inet_client_addr());
    RETURN 'Clave cambiada satisfactoriamente';
END;
$$ LANGUAGE plpgsql;