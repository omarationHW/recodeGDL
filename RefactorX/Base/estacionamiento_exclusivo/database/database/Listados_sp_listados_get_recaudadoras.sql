-- Stored Procedure: sp_listados_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene todas las recaudadoras para el formulario de Listados.
-- Generado para formulario: Listados
-- Fecha: 2025-08-27 13:56:06

CREATE OR REPLACE FUNCTION sp_listados_get_recaudadoras()
RETURNS TABLE(id_rec smallint, id_zona integer, recaudadora varchar, domicilio varchar, tel varchar, recaudador varchar, sector varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador, sector FROM padron_licencias.comun.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;