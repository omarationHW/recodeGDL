-- Stored Procedure: get_mercados_by_recaudadora
-- Tipo: Catalog
-- Descripción: Devuelve los mercados activos de una recaudadora.
-- Generado para formulario: EstadPagosyAdeudos
-- Fecha: 2025-08-27 00:00:48

CREATE OR REPLACE FUNCTION get_mercados_by_recaudadora(p_rec smallint)
RETURNS TABLE(num_mercado_nvo smallint, descripcion varchar, categoria smallint, cuenta_ingreso int, cuenta_energia int, id_zona smallint, tipo_emision varchar) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion, categoria, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision FROM ta_11_mercados WHERE oficina = p_rec AND tipo_emision <> 'B' ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;