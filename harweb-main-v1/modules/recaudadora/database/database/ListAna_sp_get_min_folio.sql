-- Stored Procedure: sp_get_min_folio
-- Tipo: Report
-- Descripción: Obtiene el folio mínimo para una caja, recaudadora y fecha.
-- Generado para formulario: ListAna
-- Fecha: 2025-08-27 12:52:10

CREATE OR REPLACE FUNCTION sp_get_min_folio(p_fecha DATE, p_caja VARCHAR, p_recaud SMALLINT)
RETURNS TABLE(minimo INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT MIN(folio) AS minimo FROM pagos WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;