-- Stored Procedure: sp_get_categorias
-- Tipo: Catalog
-- Descripción: Obtiene todas las categorías
-- Generado para formulario: ModuloBD
-- Fecha: 2025-08-27 20:46:50

DROP FUNCTION IF EXISTS sp_get_categorias();

CREATE OR REPLACE FUNCTION sp_get_categorias()
RETURNS TABLE(categoria smallint, descripcion varchar(30))
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY SELECT t.categoria, t.descripcion FROM ta_11_categoria t ORDER BY t.categoria;
END; $$;