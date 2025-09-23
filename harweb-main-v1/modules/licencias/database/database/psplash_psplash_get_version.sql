-- Stored Procedure: psplash_get_version
-- Tipo: Catalog
-- Descripción: Devuelve la versión de la aplicación, nombre y metadatos para mostrar en el splash.
-- Generado para formulario: psplash
-- Fecha: 2025-08-27 19:01:21

CREATE OR REPLACE FUNCTION psplash_get_version()
RETURNS TABLE(version TEXT, app_name TEXT, copyright TEXT, company TEXT) AS $$
BEGIN
  -- Estos valores pueden ser parametrizables o leídos de una tabla de configuración
  version := '1.0.0.0';
  app_name := 'LICENCIAS';
  copyright := '© 2024 Municipio';
  company := 'Ayuntamiento de Ejemplo';
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;