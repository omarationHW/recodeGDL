-- Stored Procedure: sp_add_mercado
-- Tipo: CRUD
-- Descripción: Agrega un nuevo mercado
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_add_mercado(_oficina integer, _num_mercado_nvo integer, _categoria integer, _descripcion varchar, _cuenta_ingreso integer, _cuenta_energia integer, _zona integer, _tipo_emision varchar)
RETURNS TABLE(oficina integer, num_mercado_nvo integer, categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO ta_11_mercados (oficina, num_mercado_nvo, categoria, descripcion, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision)
  VALUES (_oficina, _num_mercado_nvo, _categoria, UPPER(_descripcion), _cuenta_ingreso, _cuenta_energia, _zona, _tipo_emision);
  RETURN QUERY SELECT oficina, num_mercado_nvo, categoria, descripcion FROM ta_11_mercados WHERE oficina = _oficina AND num_mercado_nvo = _num_mercado_nvo;
END; $$;