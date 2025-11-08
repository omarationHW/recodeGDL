-- Stored Procedure: sp_categorias_list
-- Tipo: Catalog
-- Descripción: Lista todas las categorías de mercado
-- Generado para formulario: CuotasMdo
-- Fecha: 2025-08-26 23:34:39

CREATE OR REPLACE FUNCTION sp_categorias_list()
RETURNS TABLE (categoria INTEGER, descripcion VARCHAR(100)) AS $$
BEGIN
    RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria ORDER BY categoria;
END;
$$ LANGUAGE plpgsql;