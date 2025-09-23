-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: TDMConection
-- Generado: 2025-08-27 15:53:19
-- Total SPs: 2
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

-- SP 2/2: sp_get_databases
-- Tipo: Catalog
-- Descripción: Devuelve la lista de bases de datos disponibles en el servidor PostgreSQL.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_databases()
RETURNS TABLE(database_name TEXT) AS $$
BEGIN
    RETURN QUERY SELECT datname FROM pg_database WHERE datistemplate = FALSE ORDER BY datname;
END;
$$ LANGUAGE plpgsql;

-- ============================================

