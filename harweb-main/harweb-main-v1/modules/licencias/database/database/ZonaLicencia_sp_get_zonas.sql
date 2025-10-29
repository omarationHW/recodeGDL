-- Stored Procedure: sp_get_zonas
-- Tipo: Catalog
-- Descripción: Obtiene las zonas disponibles para una recaudadora
-- Generado para formulario: ZonaLicencia
-- Fecha: 2025-08-27 19:54:46

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