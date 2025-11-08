-- Stored Procedure: sp_categoria_create
-- Tipo: CRUD
-- Descripción: Crea una nueva categoría
-- Generado para formulario: Categoria
-- Fecha: 2025-08-26 23:08:08

CREATE OR REPLACE FUNCTION sp_categoria_create(p_categoria smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_11_categoria WHERE categoria = p_categoria;
  IF existe > 0 THEN
    RETURN QUERY SELECT false, 'La categoría ya existe';
    RETURN;
  END IF;
  INSERT INTO ta_11_categoria (categoria, descripcion) VALUES (p_categoria, UPPER(p_descripcion));
  RETURN QUERY SELECT true, 'Categoría creada correctamente';
END;$$;