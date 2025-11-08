-- Stored Procedure: sp_get_recargos_mes
-- Tipo: Report
-- Descripción: Obtiene los recargos de un año y mes.
-- Generado para formulario: RptEmisionLaser
-- Fecha: 2025-08-27 20:48:44

CREATE OR REPLACE FUNCTION sp_get_recargos_mes(p_axo integer, p_mes integer)
RETURNS TABLE(
  porcentaje_mes numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT porcentaje_mes FROM ta_12_recargos WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;