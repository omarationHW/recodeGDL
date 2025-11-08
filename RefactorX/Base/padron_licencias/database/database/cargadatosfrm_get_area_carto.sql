-- Stored Procedure: get_area_carto
-- Tipo: Catalog
-- Descripción: Obtiene el área de construcción cartográfica para una clave catastral
-- Generado para formulario: cargadatosfrm
-- Fecha: 2025-08-27 16:39:10

CREATE OR REPLACE FUNCTION get_area_carto(p_cvecatnva TEXT)
RETURNS TABLE(supconst NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT SUM(areaconst) AS supconst
  FROM construc_carto
  WHERE cvecatnva = p_cvecatnva AND vigente = 'V';
END;
$$ LANGUAGE plpgsql;