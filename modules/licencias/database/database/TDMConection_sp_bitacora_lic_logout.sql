-- Stored Procedure: sp_bitacora_lic_logout
-- Tipo: CRUD
-- Descripción: Registra el fin de sesión en la bitácora.
-- Generado para formulario: TDMConection
-- Fecha: 2025-08-26 18:15:59

CREATE OR REPLACE PROCEDURE sp_bitacora_lic_logout(p_id_bitacora INTEGER, p_fecha_fin TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE bitacora_lic_login
    SET fecha_fin = p_fecha_fin
    WHERE id = p_id_bitacora;
END;
$$;