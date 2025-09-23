-- Stored Procedure: sp_categorias_list
-- Tipo: Catalog
-- Descripción: Lista de categorías de mercado
-- Generado para formulario: CatalogoMntto
-- Fecha: 2025-08-26 23:06:58

CREATE OR REPLACE FUNCTION sp_categorias_list()
RETURNS TABLE (categoria INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria;
END;
$$ LANGUAGE plpgsql;