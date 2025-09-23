-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SFRM_CHGPASS (EXACTO del archivo original)
-- Archivo: 114_SP_RECAUDADORA_SFRM_CHGPASS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
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

