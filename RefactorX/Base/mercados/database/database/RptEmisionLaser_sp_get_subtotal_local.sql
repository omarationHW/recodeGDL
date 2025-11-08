-- Stored Procedure: sp_get_subtotal_local
-- Tipo: Report
-- Descripción: Obtiene el subtotal de adeudo y recargos de un local.
-- Generado para formulario: RptEmisionLaser
-- Fecha: 2025-08-27 20:48:44

CREATE OR REPLACE FUNCTION sp_get_subtotal_local(p_id_local integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
  adeudo numeric,
  recargos numeric,
  subtotalcalc numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT COALESCE(SUM(d.importe),0) AS adeudo,
         COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS recargos,
         COALESCE(SUM(d.importe),0) + COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS subtotalcalc
  FROM ta_11_adeudo_local d
  WHERE d.id_local = p_id_local AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo));
END;
$$ LANGUAGE plpgsql;