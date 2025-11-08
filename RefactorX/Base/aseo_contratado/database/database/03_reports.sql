CREATE OR REPLACE FUNCTION con16_detade_021(p_control integer)
RETURNS TABLE (
  expression integer,
  expression_1 varchar,
  expression_2 varchar,
  expression_3 integer,
  expression_4 integer,
  expression_5 numeric,
  expression_6 numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.control_contrato,
    to_char(p.aso_mes_pago, 'YYYY-MM'),
    o.descripcion,
    p.ctrol_operacion,
    p.exedencias,
    p.importe,
    0.0
  FROM ta_16_pagos p
  JOIN ta_16_operacion o ON o.ctrol_operacion = p.ctrol_operacion
  WHERE p.control_contrato = p_control
    AND p.status_vigencia = 'V';
END;
$$ LANGUAGE plpgsql;