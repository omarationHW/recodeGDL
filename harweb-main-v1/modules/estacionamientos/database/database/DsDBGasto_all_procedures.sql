-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: DsDBGasto
-- Generado: 2025-08-27 13:34:39
-- Total SPs: 2
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

-- SP 2/2: sp_connect_estacion
-- Tipo: CRUD
-- Descripción: Simula la conexión a la base de datos de estación usando credenciales fijas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_connect_estacion()
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    -- Simulación: Verifica si el usuario 'estacion' existe en la tabla de usuarios de estación
    SELECT COUNT(*) INTO v_exists FROM estacion_usuarios WHERE username = 'estacion' AND password = '3st4c10n';
    IF v_exists > 0 THEN
        RETURN QUERY SELECT TRUE, 'Conexión a estación exitosa';
    ELSE
        RETURN QUERY SELECT FALSE, 'No se pudo conectar a estación';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

