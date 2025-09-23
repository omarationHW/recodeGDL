-- Stored Procedure: sp_categoria_list
-- Tipo: Catalog
-- Descripción: Devuelve todas las categorías de la tabla ta_11_categoria.
-- Generado para formulario: CategoriaMntto
-- Fecha: 2025-08-26 23:09:13

CREATE OR REPLACE FUNCTION sp_categoria_list()
RETURNS TABLE(categoria smallint, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria ASC;
END;
$$ LANGUAGE plpgsql;