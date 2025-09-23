-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PSPLASH (EXACTO del archivo original)
-- Archivo: 81_SP_LICENCIAS_PSPLASH_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PSPLASH (EXACTO del archivo original)
-- Archivo: 81_SP_LICENCIAS_PSPLASH_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

