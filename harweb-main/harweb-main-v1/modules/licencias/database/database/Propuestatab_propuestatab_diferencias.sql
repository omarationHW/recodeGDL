-- Stored Procedure: propuestatab_diferencias
-- Tipo: Report
-- Descripción: Obtiene las diferencias de valores históricos de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-27 18:59:08

CREATE OR REPLACE FUNCTION propuestatab_diferencias(p_cvecuenta INTEGER)
RETURNS TABLE(
  id SERIAL,
  bimini INTEGER,
  axoini INTEGER,
  bimfin INTEGER,
  axofin INTEGER,
  tasaant NUMERIC,
  stasaant NUMERIC,
  valfisant NUMERIC,
  tasa NUMERIC,
  axosobretasa NUMERIC,
  valfiscal NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT d.id, d.bimini, d.axoini, d.bimfin, d.axofin, d.tasaant, d.stasaant, d.valfisant, d.tasa, d.axosobretasa, d.valfiscal
  FROM diferencias d
  WHERE d.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;