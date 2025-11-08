-- Stored Procedure: get_construcciones
-- Tipo: Catalog
-- Descripción: Obtiene las construcciones asociadas a un avalúo
-- Generado para formulario: cargadatosfrm
-- Fecha: 2025-08-27 16:39:10

CREATE OR REPLACE FUNCTION get_construcciones(p_cveavaluo INT)
RETURNS TABLE(
  cvebloque INT,
  cveclasif INT,
  descripcion TEXT,
  areaconst NUMERIC,
  importe NUMERIC,
  numpisos INT,
  estructura TEXT,
  factorajus NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.cvebloque, a.cveclasif, b.descripcion, a.areaconst, a.importe, a.numpisos, a.estructura, a.factorajus
  FROM construc a
  LEFT JOIN c_bloqcon b ON b.axovig = a.axovig AND b.cveclasif = a.cveclasif
  WHERE a.cveavaluo = p_cveavaluo;
END;
$$ LANGUAGE plpgsql;