-- Stored Procedure: sp_bitacora_chgpass
-- Tipo: CRUD
-- Descripción: Registra el cambio de clave en la bitácora de seguridad.
-- Generado para formulario: sfrm_chgpass
-- Fecha: 2025-08-26 18:09:13

CREATE OR REPLACE FUNCTION sp_bitacora_chgpass(
    p_user_id INT,
    p_fecha TIMESTAMP,
    p_ip INET
) RETURNS VOID AS $$
BEGIN
    INSERT INTO bitacora_chgpass(user_id, fecha, ip)
    VALUES (p_user_id, p_fecha, p_ip);
END;
$$ LANGUAGE plpgsql;