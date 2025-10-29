-- Stored Procedure: sp_cancel_autorizados
-- Tipo: CRUD
-- Descripción: Cancela los autorizados vigentes para un control y fecha de alta.
-- Generado para formulario: ReportAutor
-- Fecha: 2025-08-27 14:26:10

CREATE OR REPLACE FUNCTION sp_cancel_autorizados(p_id_control integer, p_fecha_alta date)
RETURNS TABLE (updated integer) AS $$
BEGIN
  UPDATE ta_15_autorizados
  SET fecha_baja = CURRENT_DATE, estado = 2
  WHERE control = p_id_control AND fecha_alta = p_fecha_alta AND estado = 1;
  RETURN QUERY SELECT 1;
END;
$$ LANGUAGE plpgsql;