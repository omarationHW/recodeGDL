-- Stored Procedure: propuestatab_regimen
-- Tipo: Catalog
-- Descripción: Obtiene el régimen de propiedad de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-27 18:59:08

CREATE OR REPLACE FUNCTION propuestatab_regimen(p_cvecuenta INTEGER)
RETURNS TABLE(
  cvereg INTEGER,
  encabeza VARCHAR,
  porcentaje NUMERIC,
  descripcion VARCHAR,
  exento VARCHAR,
  ncompleto VARCHAR,
  rfc VARCHAR,
  calle VARCHAR,
  noexterior VARCHAR,
  interior VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT r.cvereg, r.encabeza, r.porcentaje, r.descripcion, r.exento,
         r.ncompleto, r.rfc, r.calle, r.noexterior, r.interior
  FROM regimen_propiedad r
  WHERE r.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;