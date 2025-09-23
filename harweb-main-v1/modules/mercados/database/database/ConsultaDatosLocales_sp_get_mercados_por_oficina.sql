-- Stored Procedure: sp_get_mercados_por_oficina
-- Tipo: Catalog
-- Descripción: Devuelve los mercados de una oficina
-- Generado para formulario: ConsultaDatosLocales
-- Fecha: 2025-08-26 23:26:39

CREATE OR REPLACE FUNCTION sp_get_mercados_por_oficina(p_oficina smallint)
RETURNS TABLE(num_mercado_nvo smallint, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion FROM ta_11_mercados WHERE oficina = p_oficina ORDER BY num_mercado_nvo;
END; $$ LANGUAGE plpgsql;