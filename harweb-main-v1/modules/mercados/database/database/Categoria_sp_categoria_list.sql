-- Stored Procedure: sp_categoria_list
-- Tipo: Catalog
-- Descripción: Lista todas las categorías
-- Generado para formulario: Categoria
-- Fecha: 2025-08-26 23:08:08

CREATE OR REPLACE FUNCTION sp_categoria_list()
RETURNS TABLE(categoria smallint, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria ASC;
END;$$;