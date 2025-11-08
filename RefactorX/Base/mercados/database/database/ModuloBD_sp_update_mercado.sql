-- Stored Procedure: sp_update_mercado
-- Tipo: CRUD
-- Descripción: Actualiza un mercado existente
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_update_mercado(_oficina integer, _num_mercado_nvo integer, _categoria integer, _descripcion varchar, _cuenta_ingreso integer, _cuenta_energia integer, _zona integer, _tipo_emision varchar)
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_mercados SET categoria=_categoria, descripcion=UPPER(_descripcion), cuenta_ingreso=_cuenta_ingreso, cuenta_energia=_cuenta_energia, id_zona=_zona, tipo_emision=_tipo_emision
  WHERE oficina=_oficina AND num_mercado_nvo=_num_mercado_nvo;
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion FROM ta_11_mercados WHERE oficina=_oficina AND num_mercado_nvo=_num_mercado_nvo;
END; $$;