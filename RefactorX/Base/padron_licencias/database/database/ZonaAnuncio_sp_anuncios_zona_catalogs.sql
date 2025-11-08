-- Stored Procedure: sp_anuncios_zona_catalogs
-- Tipo: Catalog
-- Descripción: Obtiene catálogos de zonas, subzonas y recaudadoras
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-26 18:26:24

CREATE OR REPLACE FUNCTION sp_anuncios_zona_catalogs()
RETURNS JSON AS $$
DECLARE
  zonas JSON;
  subzonas JSON;
  recaudadoras JSON;
BEGIN
  SELECT json_agg(row_to_json(t)) INTO zonas FROM (SELECT cvezona, zona, descripcion FROM c_zonas ORDER BY cvezona) t;
  SELECT json_agg(row_to_json(t)) INTO subzonas FROM (SELECT cvezona, cvesubzona, descsubzon, descripcion FROM c_subzonas ORDER BY cvezona, cvesubzona) t;
  SELECT json_agg(row_to_json(t)) INTO recaudadoras FROM (SELECT recaud, descripcion FROM c_recaud ORDER BY recaud) t;
  RETURN json_build_object('zonas', zonas, 'subzonas', subzonas, 'recaudadoras', recaudadoras);
END;
$$ LANGUAGE plpgsql;