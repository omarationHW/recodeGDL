-- Stored Procedure: get_mercados_by_oficina
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una recaudadora con energía
-- Generado para formulario: EnergiaMtto
-- Fecha: 2025-08-26 23:57:51

CREATE OR REPLACE FUNCTION get_mercados_by_oficina(p_oficina integer) RETURNS TABLE(num_mercado_nvo integer, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = p_oficina AND cuenta_energia IS NOT NULL ORDER BY num_mercado_nvo;
END; $$ LANGUAGE plpgsql;