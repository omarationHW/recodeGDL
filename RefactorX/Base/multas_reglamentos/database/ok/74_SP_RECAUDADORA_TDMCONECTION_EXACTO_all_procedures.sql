-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: TDMCONECTION (EXACTO del archivo original)
-- Archivo: 74_SP_RECAUDADORA_TDMCONECTION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_test_connection
-- Tipo: CRUD
-- Descripción: Verifica si las credenciales de usuario y contraseña permiten conectarse a la base de datos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_test_connection(p_user TEXT, p_password TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_ok BOOLEAN := FALSE;
BEGIN
    -- Intenta autenticar al usuario usando la función de PostgreSQL
    PERFORM 1 FROM pg_user WHERE usename = p_user;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Usuario no existe.';
        RETURN;
    END IF;
    -- Intenta conectarse usando dblink (requiere extensión dblink)
    BEGIN
        PERFORM dblink_connect('conn_test', 'dbname=' || current_database() || ' user=' || p_user || ' password=' || p_password);
        v_ok := TRUE;
        PERFORM dblink_disconnect('conn_test');
    EXCEPTION WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, 'Usuario o contraseña incorrectos.';
        RETURN;
    END;
    IF v_ok THEN
        RETURN QUERY SELECT TRUE, 'Conexión exitosa.';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: TDMCONECTION (EXACTO del archivo original)
-- Archivo: 74_SP_RECAUDADORA_TDMCONECTION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

