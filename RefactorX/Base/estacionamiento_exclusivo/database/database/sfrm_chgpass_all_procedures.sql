-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_chgpass
-- Generado: 2025-08-27 15:16:41
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_validate_current_password
-- Tipo: CRUD
-- Descripción: Valida la clave actual del usuario (retorna true/false y mensaje)
-- --------------------------------------------

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

-- ============================================

-- SP 2/2: sp_change_password
-- Tipo: CRUD
-- Descripción: Cambia la clave del usuario con todas las validaciones de negocio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_change_password(
    p_user_id integer,
    p_current_password text,
    p_new_password text,
    p_confirm_password text
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_clave text;
    v_user record;
BEGIN
    SELECT * INTO v_user FROM usuarios WHERE id_usuario = p_user_id;
    IF v_user IS NULL THEN
        RETURN QUERY SELECT false, 'Usuario no encontrado';
        RETURN;
    END IF;
    v_clave := v_user.clave;
    IF crypt(p_current_password, v_clave) <> v_clave THEN
        RETURN QUERY SELECT false, 'La clave actual no es correcta';
        RETURN;
    END IF;
    IF p_new_password <> p_confirm_password THEN
        RETURN QUERY SELECT false, 'La nueva clave no es igual a la confirmación';
        RETURN;
    END IF;
    IF length(p_new_password) < 6 OR length(p_new_password) > 8 THEN
        RETURN QUERY SELECT false, 'La clave debe tener entre 6 y 8 caracteres';
        RETURN;
    END IF;
    IF p_new_password = p_current_password THEN
        RETURN QUERY SELECT false, 'La clave nueva no debe ser igual a la actual';
        RETURN;
    END IF;
    IF substring(p_new_password from 1 for 3) = substring(p_current_password from 1 for 3) THEN
        RETURN QUERY SELECT false, 'Los tres primeros caracteres de la nueva clave deben ser diferentes a la actual';
        RETURN;
    END IF;
    IF NOT (p_new_password ~ '[a-z]') OR NOT (p_new_password ~ '[0-9]') THEN
        RETURN QUERY SELECT false, 'La clave debe contener letras y números';
        RETURN;
    END IF;
    UPDATE usuarios SET clave = crypt(p_new_password, gen_salt('bf')) WHERE id_usuario = p_user_id;
    RETURN QUERY SELECT true, 'Clave cambiada satisfactoriamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

