-- Stored Procedure: get_mercados_by_recaudadora
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una recaudadora.
-- Generado para formulario: PagosLocGrl
-- Fecha: 2025-08-27 00:26:11

CREATE OR REPLACE FUNCTION get_mercados_by_recaudadora(rec_id smallint)
RETURNS TABLE(num_mercado_nvo smallint, descripcion varchar, categoria smallint, cuenta_ingreso integer) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion, categoria, cuenta_ingreso FROM ta_11_mercados WHERE oficina = rec_id ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;