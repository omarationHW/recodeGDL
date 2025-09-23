-- Stored Procedure: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene la lista de recaudadoras activas.
-- Generado para formulario: EmisionLibertad
-- Fecha: 2025-08-26 23:51:55

CREATE OR REPLACE FUNCTION get_recaudadoras()
RETURNS TABLE(id_rec INT, recaudadora TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras WHERE id_rec >= 1 ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;