-- Stored Procedure: edo_cuenta_sum_pagos
-- Tipo: CRUD
-- Descripción: Suma los pagos y recargos de un convenio para mostrar totales.
-- Generado para formulario: EdoCuenta
-- Fecha: 2025-08-27 14:27:45

CREATE OR REPLACE FUNCTION edo_cuenta_sum_pagos(p_id_conv_resto integer)
RETURNS TABLE(
  total_importe numeric,
  total_recargo numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT COALESCE(SUM(importe_pago),0), COALESCE(SUM(COALESCE(importe_recargo,0)),0)
  FROM ta_17_conv_pagos
  WHERE id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;