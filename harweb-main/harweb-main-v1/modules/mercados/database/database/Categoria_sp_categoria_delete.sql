-- Stored Procedure: sp_categoria_delete
-- Tipo: CRUD
-- Descripción: Elimina una categoría
-- Generado para formulario: Categoria
-- Fecha: 2025-08-26 23:08:08

CREATE OR REPLACE FUNCTION sp_categoria_delete(p_categoria smallint)
RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_11_categoria WHERE categoria = p_categoria;
  IF existe = 0 THEN
    RETURN QUERY SELECT false, 'La categoría no existe';
    RETURN;
  END IF;
  DELETE FROM ta_11_categoria WHERE categoria = p_categoria;
  RETURN QUERY SELECT true, 'Categoría eliminada correctamente';
END;$$;