-- Stored Procedure: sp_categoria_create
-- Tipo: CRUD
-- Descripción: Inserta una nueva categoría en ta_11_categoria.
-- Generado para formulario: CategoriaMntto
-- Fecha: 2025-08-26 23:09:13

CREATE OR REPLACE FUNCTION sp_categoria_create(p_categoria smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM ta_11_categoria WHERE categoria = p_categoria) THEN
    RETURN QUERY SELECT false, 'La categoría ya existe';
  ELSE
    INSERT INTO ta_11_categoria (categoria, descripcion) VALUES (p_categoria, p_descripcion);
    RETURN QUERY SELECT true, 'Categoría creada correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;