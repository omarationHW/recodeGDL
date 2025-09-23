-- Stored Procedure: sp_categoria_list
-- Tipo: Catalog
-- Descripción: Lista todas las categorías
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 00:16:13

CREATE OR REPLACE FUNCTION sp_categoria_list()
RETURNS TABLE(categoria smallint, descripcion varchar(30))
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria ASC;
END;$$;