-- Stored Procedure: sp_log_splash_access
-- Tipo: CRUD
-- Descripción: Registra el acceso al splash screen para auditoría o estadísticas
-- Generado para formulario: psplash
-- Fecha: 2025-08-26 17:36:56

CREATE OR REPLACE FUNCTION sp_log_splash_access(p_user TEXT, p_ip TEXT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO splash_access_log(user_name, access_time, ip_address)
    VALUES (p_user, NOW(), p_ip);
END;
$$ LANGUAGE plpgsql;