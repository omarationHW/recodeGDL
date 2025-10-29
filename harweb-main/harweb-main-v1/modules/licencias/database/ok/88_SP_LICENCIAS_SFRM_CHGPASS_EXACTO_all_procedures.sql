-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SFRM_CHGPASS (EXACTO del archivo original)
-- Archivo: 88_SP_LICENCIAS_SFRM_CHGPASS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_validate_user_password
-- Tipo: CRUD
-- Descripción: Valida si la contraseña actual es correcta para el usuario dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_validate_user_password(p_username TEXT, p_password TEXT)
RETURNS TABLE(is_valid BOOLEAN) AS $$
BEGIN
  RETURN QUERY
    SELECT (u.password_hash = crypt(p_password, u.password_hash)) AS is_valid
    FROM users u WHERE u.username = p_username;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SFRM_CHGPASS (EXACTO del archivo original)
-- Archivo: 88_SP_LICENCIAS_SFRM_CHGPASS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

