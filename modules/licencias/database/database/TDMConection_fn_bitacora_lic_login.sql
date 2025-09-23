-- Stored Procedure: fn_bitacora_lic_login
-- Tipo: CRUD
-- Descripción: Registra el inicio de sesión en la bitácora y retorna el id insertado.
-- Generado para formulario: TDMConection
-- Fecha: 2025-08-26 18:15:59

CREATE OR REPLACE FUNCTION fn_bitacora_lic_login(p_fecha_inicio TIMESTAMP, p_usuario VARCHAR, p_ip VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO bitacora_lic_login (fecha_inicio, usuario, nombre_pc, ip)
    VALUES (p_fecha_inicio, p_usuario, inet_client_host(), p_ip)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;