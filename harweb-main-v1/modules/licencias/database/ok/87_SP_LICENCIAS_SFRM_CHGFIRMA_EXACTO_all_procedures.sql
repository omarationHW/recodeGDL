-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: SFRM_CHGFIRMA (EXACTO del archivo original)
-- Archivo: 87_SP_LICENCIAS_SFRM_CHGFIRMA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: upd_firma
-- Tipo: CRUD
-- Descripción: Actualiza la firma electrónica de un usuario para un módulo específico. Valida la firma actual, la nueva y la confirmación.
-- --------------------------------------------

-- PostgreSQL stored procedure for updating electronic signature
CREATE OR REPLACE FUNCTION upd_firma(
    p_usuario VARCHAR,
    p_login VARCHAR,
    p_firma VARCHAR,
    p_firma_nva VARCHAR,
    p_firma_conf VARCHAR,
    p_modulos_id INTEGER
)
RETURNS TABLE(acceso INTEGER, mensaje VARCHAR) AS $$
DECLARE
    v_usuario_id INTEGER;
    v_firma_actual VARCHAR;
BEGIN
    -- Validar existencia de usuario
    SELECT id INTO v_usuario_id FROM usuarios WHERE usuario = p_usuario;
    IF v_usuario_id IS NULL THEN
        RETURN QUERY SELECT 1, 'Usuario no encontrado';
        RETURN;
    END IF;

    -- Validar firma actual
    SELECT firma INTO v_firma_actual FROM usuarios_firma WHERE usuario_id = v_usuario_id AND modulos_id = p_modulos_id;
    IF v_firma_actual IS NULL THEN
        RETURN QUERY SELECT 1, 'No tiene firma registrada para este módulo';
        RETURN;
    END IF;
    IF v_firma_actual <> p_firma THEN
        RETURN QUERY SELECT 1, 'La firma actual es incorrecta';
        RETURN;
    END IF;

    -- Validar nueva firma
    IF length(p_firma_nva) < 6 THEN
        RETURN QUERY SELECT 1, 'La nueva firma debe tener al menos 6 caracteres';
        RETURN;
    END IF;
    IF p_firma_nva <> p_firma_conf THEN
        RETURN QUERY SELECT 1, 'La confirmación no coincide';
        RETURN;
    END IF;
    IF p_firma_nva = p_firma THEN
        RETURN QUERY SELECT 1, 'La nueva firma no puede ser igual a la actual';
        RETURN;
    END IF;

    -- Actualizar firma
    UPDATE usuarios_firma SET firma = p_firma_nva, fecha_mod = now()
    WHERE usuario_id = v_usuario_id AND modulos_id = p_modulos_id;

    RETURN QUERY SELECT 0, 'Firma electrónica actualizada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

