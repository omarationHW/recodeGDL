-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: DSDBGASTO (EXACTO del archivo original)
-- Archivo: 13_SP_ESTACIONAMIENTOS_DSDBGASTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_login_seguridad
-- Tipo: CRUD
-- Descripción: Verifica las credenciales del usuario contra la base de datos de seguridad.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_login_seguridad(p_user TEXT, p_pass TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM seguridad_usuarios WHERE username = p_user AND password = p_pass;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT TRUE, 'Login correcto';
    ELSE
        RETURN QUERY SELECT FALSE, 'Usuario o contraseña incorrectos';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: DSDBGASTO (EXACTO del archivo original)
-- Archivo: 13_SP_ESTACIONAMIENTOS_DSDBGASTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

