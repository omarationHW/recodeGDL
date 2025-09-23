-- Stored Procedure: sp_get_fecha_descuento
-- Tipo: Report
-- Descripción: Obtiene la fecha de descuento para un mes.
-- Generado para formulario: RptEmisionLaser
-- Fecha: 2025-08-27 20:48:44

CREATE OR REPLACE FUNCTION sp_get_fecha_descuento(p_mes integer)
RETURNS TABLE(
  fecha_descuento date,
  fecha_recargos date
) AS $$
BEGIN
  RETURN QUERY
  SELECT fecha_descuento, fecha_recargos FROM ta_11_fecha_desc WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;