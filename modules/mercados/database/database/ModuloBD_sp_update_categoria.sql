-- Stored Procedure: sp_update_categoria
-- Tipo: CRUD
-- Descripción: Actualiza una categoría existente
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_update_categoria(_categoria integer, _descripcion varchar)
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE ta_11_categoria SET descripcion = UPPER(_descripcion) WHERE categoria = _categoria;
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria WHERE categoria = _categoria;
END; $$;