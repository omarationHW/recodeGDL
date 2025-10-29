-- Stored Procedure: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene el catálogo de recaudadoras.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-28 13:01:07

CREATE OR REPLACE FUNCTION sp_get_recaudadoras()
RETURNS TABLE(
  id_rec smallint,
  id_zona integer,
  recaudadora text,
  domicilio text,
  tel text,
  recaudador text,
  sector text
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador, sector
  FROM ta_12_recaudadoras
  ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;