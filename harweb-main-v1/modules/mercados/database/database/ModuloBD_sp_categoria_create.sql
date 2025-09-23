-- Stored Procedure: sp_categoria_create
-- Tipo: CRUD
-- Descripción: Crea una nueva categoría
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 00:16:13

CREATE OR REPLACE FUNCTION sp_categoria_create(p_categoria smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM ta_11_categoria WHERE categoria = p_categoria) THEN
    RETURN QUERY SELECT false, 'La categoría ya existe';
  ELSE
    INSERT INTO ta_11_categoria (categoria, descripcion) VALUES (p_categoria, UPPER(p_descripcion));
    RETURN QUERY SELECT true, 'Categoría creada correctamente';
  END IF;
END;$$;