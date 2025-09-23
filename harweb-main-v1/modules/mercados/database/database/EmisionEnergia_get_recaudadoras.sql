-- Stored Procedure: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve la lista de recaudadoras activas.
-- Generado para formulario: EmisionEnergia
-- Fecha: 2025-08-26 23:50:10

CREATE OR REPLACE FUNCTION get_recaudadoras() RETURNS TABLE(id_rec INT, recaudadora TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;