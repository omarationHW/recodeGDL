-- Stored Procedure: sp_login_seguridad
-- Tipo: CRUD
-- Descripción: Verifica las credenciales del usuario contra la base de datos de seguridad.
-- Generado para formulario: DsDBGasto
-- Fecha: 2025-08-27 13:34:39

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