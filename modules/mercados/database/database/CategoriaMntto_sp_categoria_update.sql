-- Stored Procedure: sp_categoria_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una categoría existente.
-- Generado para formulario: CategoriaMntto
-- Fecha: 2025-08-26 23:09:13

CREATE OR REPLACE FUNCTION sp_categoria_update(p_categoria smallint, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ta_11_categoria WHERE categoria = p_categoria) THEN
    RETURN QUERY SELECT false, 'La categoría no existe';
  ELSE
    UPDATE ta_11_categoria SET descripcion = p_descripcion WHERE categoria = p_categoria;
    RETURN QUERY SELECT true, 'Categoría actualizada correctamente';
  END IF;
END;
$$ LANGUAGE plpgsql;