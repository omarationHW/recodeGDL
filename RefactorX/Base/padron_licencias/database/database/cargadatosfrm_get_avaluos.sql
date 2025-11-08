-- Stored Procedure: get_avaluos
-- Tipo: Catalog
-- Descripción: Obtiene los avalúos de una cuenta catastral y subpredio
-- Generado para formulario: cargadatosfrm
-- Fecha: 2025-08-27 16:39:10

CREATE OR REPLACE FUNCTION get_avaluos(p_cvecatnva TEXT, p_subpredio INT)
RETURNS TABLE(
  cveavaluo INT,
  supterr NUMERIC,
  supconst NUMERIC,
  valorterr NUMERIC,
  valorconst NUMERIC,
  valfiscal NUMERIC,
  feccap DATE
) AS $$
BEGIN
  RETURN QUERY
  SELECT cveavaluo, supterr, supconst, valorterr, valorconst, valfiscal, feccap
  FROM avaluos
  WHERE cvecatnva = p_cvecatnva AND (subpredio = p_subpredio OR p_subpredio = 0)
  ORDER BY feccap DESC;
END;
$$ LANGUAGE plpgsql;