-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: SFRM_CHGPASS (EXACTO del archivo original)
-- Archivo: 36_SP_CEMENTERIOS_SFRM_CHGPASS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_chgpass_validate_current
-- Tipo: CRUD
-- Descripción: Valida si la clave actual ingresada corresponde al usuario autenticado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_chgpass_validate_current(p_user_id integer, p_current_password text)
RETURNS TABLE(is_valid boolean) AS $$
BEGIN
    RETURN QUERY
    SELECT (password = crypt(p_current_password, password)) AS is_valid
    FROM public.ta_12_passwords
    WHERE id_usuario = p_user_id AND estado = 'A';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CEMENTERIOS
-- Formulario: SFRM_CHGPASS (EXACTO del archivo original)
-- Archivo: 36_SP_CEMENTERIOS_SFRM_CHGPASS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

