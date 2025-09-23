-- Stored Procedure: sp_get_pagos_predio
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados para un predio/convenio.
-- Generado para formulario: RptEdoCuenta
-- Fecha: 2025-08-27 15:37:22

CREATE OR REPLACE FUNCTION sp_get_pagos_predio(p_id_conv_resto INTEGER)
RETURNS TABLE (
  pago_parcial SMALLINT,
  fecha_pago DATE,
  oficina_pago SMALLINT,
  caja_pago VARCHAR,
  operacion_pago INTEGER,
  importe_pago NUMERIC,
  importe_recargo NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT pago_parcial, fecha_pago, oficina_pago, caja_pago, operacion_pago, importe_pago, importe_recargo
    FROM ta_17_conv_pagos
   WHERE id_conv_resto = p_id_conv_resto
   ORDER BY pago_parcial;
END;
$$ LANGUAGE plpgsql;