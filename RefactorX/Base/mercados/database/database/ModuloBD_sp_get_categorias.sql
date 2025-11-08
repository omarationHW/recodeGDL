-- Stored Procedure: sp_get_categorias
-- Tipo: Catalog
-- Descripción: Obtiene todas las categorías
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

CREATE OR REPLACE FUNCTION sp_get_categorias()
RETURNS TABLE(categoria integer, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria;
END; $$;