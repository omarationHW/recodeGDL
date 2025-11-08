-- Stored Procedure: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de recaudadoras
-- Generado para formulario: ConsultaDatosLocales
-- Fecha: 2025-08-26 23:26:39

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(id_rec smallint, recaudadora text) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM ta_12_recaudadoras ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;