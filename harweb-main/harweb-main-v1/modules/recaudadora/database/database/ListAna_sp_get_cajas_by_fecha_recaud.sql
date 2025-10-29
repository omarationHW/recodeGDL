-- Stored Procedure: sp_get_cajas_by_fecha_recaud
-- Tipo: Catalog
-- Descripción: Obtiene las cajas disponibles para una fecha y recaudadora específica.
-- Generado para formulario: ListAna
-- Fecha: 2025-08-27 12:52:10

CREATE OR REPLACE FUNCTION sp_get_cajas_by_fecha_recaud(p_fecha DATE, p_recaud SMALLINT)
RETURNS TABLE(caja VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT caja FROM pagos WHERE fecha = p_fecha AND recaud = p_recaud;
END;
$$ LANGUAGE plpgsql;