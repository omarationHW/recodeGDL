-- Stored Procedure: sp_get_max_folio
-- Tipo: Report
-- Descripción: Obtiene el folio máximo para una caja, recaudadora y fecha.
-- Generado para formulario: ListAna
-- Fecha: 2025-08-27 12:52:10

CREATE OR REPLACE FUNCTION sp_get_max_folio(p_fecha DATE, p_caja VARCHAR, p_recaud SMALLINT)
RETURNS TABLE(maximo INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT MAX(folio) AS maximo FROM pagos WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;