-- Stored Procedure: sp_zonaanuncio_catalogs
-- Tipo: Catalog
-- Descripción: Devuelve catálogos de zonas, subzonas y recaudadoras
-- Generado para formulario: ZonaAnuncio
-- Fecha: 2025-08-27 19:51:59

CREATE OR REPLACE FUNCTION sp_zonaanuncio_catalogs()
RETURNS TABLE(tipo TEXT, id INTEGER, nombre TEXT, descripcion TEXT, cvezona INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT 'zona', cvezona, zona, cvezona || ' - ' || zona, cvezona FROM c_zonas;
  RETURN QUERY SELECT 'subzona', cvesubzona, descsubzon, cvesubzona || ' - ' || descsubzon, cvezona FROM c_subzonas;
  RETURN QUERY SELECT 'recaudadora', recaud, descripcion, recaud || ' - ' || descripcion, NULL FROM c_recaud WHERE recaud <= 5;
END; $$;