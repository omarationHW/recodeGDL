-- Stored Procedure: sp_categoria_delete
-- Tipo: CRUD
-- Descripción: Elimina una categoría
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 00:16:13

CREATE OR REPLACE FUNCTION sp_categoria_delete(p_categoria smallint)
RETURNS TABLE(success boolean, message text)
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM ta_11_categoria WHERE categoria = p_categoria) THEN
    RETURN QUERY SELECT false, 'La categoría no existe';
  ELSE
    DELETE FROM ta_11_categoria WHERE categoria = p_categoria;
    RETURN QUERY SELECT true, 'Categoría eliminada correctamente';
  END IF;
END;$$;