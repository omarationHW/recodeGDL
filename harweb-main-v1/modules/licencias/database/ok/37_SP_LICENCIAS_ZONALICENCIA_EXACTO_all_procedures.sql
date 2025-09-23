-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: ZONALICENCIA (EXACTO del archivo original)
-- Archivo: 37_SP_LICENCIAS_ZONALICENCIA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_get_zonas
-- Tipo: Catalog
-- Descripción: Obtiene las zonas disponibles para una recaudadora
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_zonas(p_recaud INTEGER)
RETURNS TABLE(cvezona SMALLINT, cvepoblacion INTEGER, zona VARCHAR, feccap DATE, capturista VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT z.cvezona, z.cvepoblacion, z.zona, z.feccap, z.capturista, z.cvezona || ' - ' || z.zona AS descripcion
  FROM c_zonas z
  WHERE z.cvezona IN (SELECT zona FROM c_zonayrec WHERE rec = p_recaud)
  ORDER BY z.cvezona;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: ZONALICENCIA (EXACTO del archivo original)
-- Archivo: 37_SP_LICENCIAS_ZONALICENCIA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene las recaudadoras activas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(recaud SMALLINT, descripcion VARCHAR, mpio SMALLINT, recaudador VARCHAR, domicilio VARCHAR, feccap DATE, capturista VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT recaud, descripcion, mpio, recaudador, domicilio, feccap, capturista
  FROM c_recaud
  WHERE recaud <= 5;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: ZONALICENCIA (EXACTO del archivo original)
-- Archivo: 37_SP_LICENCIAS_ZONALICENCIA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_get_licencias_zona
-- Tipo: Catalog
-- Descripción: Obtiene la zona/subzona/recaudadora de una licencia
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_licencias_zona(p_licencia INTEGER)
RETURNS TABLE(licencia INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM licencias_zona WHERE licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: ZONALICENCIA (EXACTO del archivo original)
-- Archivo: 37_SP_LICENCIAS_ZONALICENCIA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

