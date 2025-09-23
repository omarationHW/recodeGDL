-- Stored Procedure: sp_get_databases
-- Tipo: Catalog
-- Descripción: Devuelve la lista de bases de datos disponibles en el servidor PostgreSQL.
-- Generado para formulario: TDMConection
-- Fecha: 2025-08-27 15:53:19

CREATE OR REPLACE FUNCTION sp_get_databases()
RETURNS TABLE(database_name TEXT) AS $$
BEGIN
    RETURN QUERY SELECT datname FROM pg_database WHERE datistemplate = FALSE ORDER BY datname;
END;
$$ LANGUAGE plpgsql;