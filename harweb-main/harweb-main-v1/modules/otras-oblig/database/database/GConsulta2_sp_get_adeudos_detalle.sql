-- Stored Procedure: sp_get_adeudos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de un control
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-27 16:06:00

CREATE OR REPLACE FUNCTION sp_get_adeudos_detalle(par_tabla VARCHAR, par_id_datos INTEGER, par_aso INTEGER, par_mes INTEGER)
RETURNS TABLE (
  concepto VARCHAR,
  axo INTEGER,
  mes INTEGER,
  importe_pagar NUMERIC,
  recargos_pagar NUMERIC,
  dscto_importe NUMERIC,
  dscto_recargos NUMERIC,
  actualizacion_pagar NUMERIC
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM cob34_gdetade_01(par_tabla, par_id_datos, par_aso, par_mes);
END;
$$ LANGUAGE plpgsql;