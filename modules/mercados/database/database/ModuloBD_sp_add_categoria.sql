-- Stored Procedure: sp_add_categoria
-- Tipo: CRUD
-- Descripción: Agrega una nueva categoría
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_add_categoria(_descripcion varchar)
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
DECLARE
  new_id integer;
BEGIN
  SELECT COALESCE(MAX(categoria),0)+1 INTO new_id FROM ta_11_categoria;
  INSERT INTO ta_11_categoria (categoria, descripcion) VALUES (new_id, UPPER(_descripcion));
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria WHERE categoria = new_id;
END; $$;