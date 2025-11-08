-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: psplash
-- Generado: 2025-08-27 19:01:21
-- Total SPs: 2
-- ============================================

-- SP 1/2: psplash_get_version
-- Tipo: Catalog
-- Descripción: Devuelve la versión de la aplicación, nombre y metadatos para mostrar en el splash.
-- --------------------------------------------

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

-- ============================================

-- SP 2/2: psplash_get_splash_data
-- Tipo: Catalog
-- Descripción: Devuelve los textos y la imagen base64 para el splash principal.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION psplash_get_splash_data()
RETURNS TABLE(message TEXT, label_effect TEXT, image_base64 TEXT) AS $$
BEGIN
  message := 'Cargando Aplicación';
  label_effect := 'Padrón y Licencias';
  -- Imagen base64: aquí se puede almacenar en una tabla o archivo, para ejemplo se deja NULL
  image_base64 := NULL; -- O cargar desde tabla/configuración
  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

