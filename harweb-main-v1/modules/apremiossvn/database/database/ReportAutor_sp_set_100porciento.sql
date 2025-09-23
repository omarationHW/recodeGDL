-- Stored Procedure: sp_set_100porciento
-- Tipo: CRUD
-- Descripción: Actualiza el porcentaje de multa a 100% para un control.
-- Generado para formulario: ReportAutor
-- Fecha: 2025-08-27 14:26:10

CREATE OR REPLACE FUNCTION sp_set_100porciento(p_id_control integer)
RETURNS TABLE (updated integer) AS $$
BEGIN
  UPDATE ta_15_apremios SET porcentaje_multa = 100 WHERE id_control = p_id_control AND porcentaje_multa < 100;
  RETURN QUERY SELECT 1;
END;
$$ LANGUAGE plpgsql;