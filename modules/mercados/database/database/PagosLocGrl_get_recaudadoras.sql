-- Stored Procedure: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve la lista de oficinas recaudadoras.
-- Generado para formulario: PagosLocGrl
-- Fecha: 2025-08-27 00:26:11

CREATE OR REPLACE FUNCTION get_recaudadoras()
RETURNS TABLE(id_rec smallint, recaudadora varchar, domicilio varchar, tel varchar, recaudador varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora, domicilio, tel, recaudador FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;