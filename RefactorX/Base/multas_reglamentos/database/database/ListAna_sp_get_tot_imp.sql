-- Stored Procedure: sp_get_tot_imp
-- Tipo: Report
-- Descripción: Obtiene el total de importes para una caja, recaudadora y fecha.
-- Generado para formulario: ListAna
-- Fecha: 2025-08-27 12:52:10

CREATE OR REPLACE FUNCTION sp_get_tot_imp(p_fecha DATE, p_caja VARCHAR, p_recaud SMALLINT)
RETURNS TABLE(tot_imp NUMERIC) AS $$
BEGIN
  RETURN QUERY
    SELECT COALESCE(SUM(importe),0) AS tot_imp FROM pagos WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;