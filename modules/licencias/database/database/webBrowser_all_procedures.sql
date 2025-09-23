-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: webBrowser
-- Generado: 2025-08-27 19:49:54
-- Total SPs: 1
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

