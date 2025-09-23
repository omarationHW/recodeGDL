-- Stored Procedure: sp_get_subzonas
-- Tipo: Catalog
-- Descripción: Obtiene las subzonas disponibles para una zona y recaudadora
-- Generado para formulario: ZonaLicencia
-- Fecha: 2025-08-27 19:54:46

CREATE OR REPLACE FUNCTION sp_get_subzonas(p_cvezona INTEGER, p_recaud INTEGER)
RETURNS TABLE(cvezona INTEGER, cvesubzona INTEGER, descsubzon VARCHAR, feccap DATE, capturista VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT s.cvezona, s.cvesubzona, s.descsubzon, s.feccap, s.capturista, s.cvesubzona || ' - ' || s.descsubzon AS descripcion
  FROM c_subzonas s
  WHERE s.cvezona = p_cvezona
    AND s.cvesubzona IN (SELECT subzona FROM c_zonayrec WHERE rec = p_recaud AND zona = s.cvezona)
  ORDER BY s.cvesubzona;
END;
$$ LANGUAGE plpgsql;