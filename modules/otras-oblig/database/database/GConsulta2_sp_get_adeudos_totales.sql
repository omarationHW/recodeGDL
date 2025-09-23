-- Stored Procedure: sp_get_adeudos_totales
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos de un control
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-27 16:06:00

CREATE OR REPLACE FUNCTION sp_get_adeudos_totales(par_tabla VARCHAR, par_id_datos INTEGER, par_aso INTEGER, par_mes INTEGER)
RETURNS TABLE (
  cuenta INTEGER,
  obliga VARCHAR,
  concepto VARCHAR,
  importe NUMERIC
) AS $$
BEGIN
  RETURN QUERY SELECT * FROM cob34_gtotade_01(par_tabla, par_id_datos, par_aso, par_mes);
END;
$$ LANGUAGE plpgsql;