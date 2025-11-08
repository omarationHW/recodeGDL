-- Stored Procedure: propuestatab_condominio
-- Tipo: Catalog
-- Descripción: Obtiene información de condominio para la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-27 18:59:08

CREATE OR REPLACE FUNCTION propuestatab_condominio(p_cvecatnva VARCHAR)
RETURNS TABLE(
  nombre VARCHAR,
  tipocond VARCHAR,
  numpred INTEGER,
  escritura INTEGER,
  fecescrit DATE,
  areacomun NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.nombre, c.tipocond, c.numpred, c.escritura, c.fecescrit, c.areacomun
  FROM condominio c
  WHERE c.cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;