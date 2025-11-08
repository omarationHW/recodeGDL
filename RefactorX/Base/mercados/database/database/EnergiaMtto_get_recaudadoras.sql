-- Stored Procedure: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras activas
-- Generado para formulario: EnergiaMtto
-- Fecha: 2025-08-26 23:57:51

CREATE OR REPLACE FUNCTION get_recaudadoras() RETURNS TABLE(id integer, nombre text) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras WHERE estado = 'A' ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;