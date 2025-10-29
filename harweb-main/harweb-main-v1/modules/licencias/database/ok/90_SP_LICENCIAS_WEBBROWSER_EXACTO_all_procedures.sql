-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: WEBBROWSER (EXACTO del archivo original)
-- Archivo: 90_SP_LICENCIAS_WEBBROWSER_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_log_navigation_event
-- Tipo: CRUD
-- Descripción: Registra un evento de navegación de URL por parte del usuario (opcional, para auditoría).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_log_navigation_event(p_user_id integer, p_url text, p_ip text)
RETURNS void AS $$
BEGIN
    INSERT INTO navigation_events(user_id, url, ip_address, event_time)
    VALUES (p_user_id, p_url, p_ip, NOW());
END;
$$ LANGUAGE plpgsql;

-- ============================================

