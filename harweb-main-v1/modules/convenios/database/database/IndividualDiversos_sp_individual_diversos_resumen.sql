-- Stored Procedure: sp_individual_diversos_resumen
-- Tipo: Report
-- Descripción: Devuelve resumen de adeudos, pagos, intereses, recargos y totales para un convenio diverso
-- Generado para formulario: IndividualDiversos
-- Fecha: 2025-08-27 20:47:46

CREATE OR REPLACE FUNCTION sp_individual_diversos_resumen(p_id_conv_resto integer)
RETURNS TABLE(
  total_adeudos numeric,
  total_recargos numeric,
  total_intereses numeric,
  total_pagos numeric,
  total numeric
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      COALESCE(SUM(a.importe),0) AS total_adeudos,
      COALESCE(SUM(a.recargos),0) AS total_recargos,
      COALESCE(SUM(a.interes),0) AS total_intereses,
      (SELECT COALESCE(SUM(p.importe_pago),0) FROM ta_17_conv_pagos p WHERE p.id_conv_resto = p_id_conv_resto) AS total_pagos,
      COALESCE(SUM(a.importe + a.recargos + a.interes),0) AS total
    FROM ta_17_adeudos_div a
    WHERE a.id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;