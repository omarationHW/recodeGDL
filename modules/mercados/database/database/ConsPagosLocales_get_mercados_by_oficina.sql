-- Stored Procedure: get_mercados_by_oficina
-- Tipo: Catalog
-- Descripción: Obtiene mercados por oficina
-- Generado para formulario: ConsPagosLocales
-- Fecha: 2025-08-26 23:21:11

CREATE OR REPLACE FUNCTION get_mercados_by_oficina(p_oficina smallint) RETURNS TABLE(num_mercado_nvo smallint, descripcion text, categoria smallint) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion, categoria FROM ta_11_mercados WHERE oficina = p_oficina ORDER BY num_mercado_nvo;
END; $$ LANGUAGE plpgsql;