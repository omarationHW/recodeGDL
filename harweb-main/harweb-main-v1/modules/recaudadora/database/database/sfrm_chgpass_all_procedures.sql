-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrm_chgpass
-- Generado: 2025-08-27 15:44:11
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_chgpass_change_password
-- Tipo: CRUD
-- Descripción: Cambia la contraseña del usuario en la tabla users. Recibe el id del usuario y la nueva contraseña hasheada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_chgpass_change_password(p_user_id integer, p_new_password text)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_user_id integer;
BEGIN
    SELECT id INTO v_user_id FROM users WHERE id = p_user_id;
    IF NOT FOUND THEN
        RETURN QUERY SELECT false, 'Usuario no encontrado';
        RETURN;
    END IF;
    UPDATE users SET password = p_new_password WHERE id = p_user_id;
    RETURN QUERY SELECT true, 'Clave cambiada satisfactoriamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

