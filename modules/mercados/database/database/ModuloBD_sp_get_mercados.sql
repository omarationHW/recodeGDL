-- Stored Procedure: sp_get_mercados
-- Tipo: Catalog
-- Descripción: Obtiene todos los mercados
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_get_mercados()
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar, cuenta_ingreso integer, cuenta_energia integer, id_zona integer, tipo_emision varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision FROM ta_11_mercados ORDER BY oficina, num_mercado_nvo;
END; $$;