-- Stored Procedure: sp_get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene todas las recaudadoras
-- Generado para formulario: Contratos_Upd_01
-- Fecha: 2025-08-27 14:24:09

CREATE OR REPLACE FUNCTION sp_get_recaudadoras() RETURNS TABLE (id_rec smallint, id_zona integer, recaudadora varchar, domicilio varchar, tel varchar, recaudador varchar, sector varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, id_zona, recaudadora, domicilio, tel, recaudador, sector FROM ta_12_recaudadoras ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;