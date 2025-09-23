-- Stored Procedure: propuestatab_obs400
-- Tipo: Catalog
-- Descripción: Obtiene observaciones AS-400 para la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-27 18:59:08

CREATE OR REPLACE FUNCTION propuestatab_obs400(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
RETURNS TABLE(
  acomp INTEGER,
  observa VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT o.acomp, o.observa
  FROM observ_400 o
  WHERE o.recaud = p_recaud AND o.urbrus = p_urbrus AND o.cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;