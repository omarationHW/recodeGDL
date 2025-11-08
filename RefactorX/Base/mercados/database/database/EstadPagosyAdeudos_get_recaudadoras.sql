-- Stored Procedure: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el listado de recaudadoras activas.
-- Generado para formulario: EstadPagosyAdeudos
-- Fecha: 2025-08-27 00:00:48

CREATE OR REPLACE FUNCTION get_recaudadoras()
RETURNS TABLE(id_rec smallint, recaudadora varchar, domicilio varchar, tel varchar, recaudador varchar, sector varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora, domicilio, tel, recaudador, sector FROM ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;