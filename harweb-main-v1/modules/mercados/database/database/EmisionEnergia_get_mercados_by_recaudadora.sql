-- Stored Procedure: get_mercados_by_recaudadora
-- Tipo: Catalog
-- Descripción: Devuelve los mercados asociados a una recaudadora.
-- Generado para formulario: EmisionEnergia
-- Fecha: 2025-08-26 23:50:10

CREATE OR REPLACE FUNCTION get_mercados_by_recaudadora(p_oficina INT) RETURNS TABLE(num_mercado_nvo INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = p_oficina ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;