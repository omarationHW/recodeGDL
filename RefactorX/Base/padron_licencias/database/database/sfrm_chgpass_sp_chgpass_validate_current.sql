-- Stored Procedure: sp_chgpass_validate_current
-- Tipo: CRUD
-- Descripción: Valida si la clave actual proporcionada es correcta para el usuario dado.
-- Generado para formulario: sfrm_chgpass
-- Fecha: 2025-08-26 18:09:13

CREATE OR REPLACE FUNCTION sp_chgpass_validate_current(p_user_id INT, p_current_password TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    v_hash TEXT;
BEGIN
    SELECT password INTO v_hash FROM users WHERE id = p_user_id;
    IF v_hash IS NULL THEN
        RETURN FALSE;
    END IF;
    -- Usar la función de verificación de hash de PostgreSQL (ej: pgcrypto)
    IF crypt(p_current_password, v_hash) = v_hash THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;