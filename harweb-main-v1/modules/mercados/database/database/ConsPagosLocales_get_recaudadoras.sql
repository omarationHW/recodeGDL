-- Stored Procedure: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene la lista de recaudadoras
-- Generado para formulario: ConsPagosLocales
-- Fecha: 2025-08-26 23:21:11

CREATE OR REPLACE FUNCTION get_recaudadoras() RETURNS TABLE(id_rec smallint, recaudadora text) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;