-- Stored Procedure: sp_get_licencias_zona
-- Tipo: Catalog
-- Descripción: Obtiene la zona/subzona/recaudadora de una licencia
-- Generado para formulario: ZonaLicencia
-- Fecha: 2025-08-27 19:54:46

CREATE OR REPLACE FUNCTION sp_get_licencias_zona(p_licencia INTEGER)
RETURNS TABLE(licencia INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT, feccap TIMESTAMP, capturista VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT * FROM licencias_zona WHERE licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;