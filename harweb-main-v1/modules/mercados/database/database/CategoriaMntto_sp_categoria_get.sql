-- Stored Procedure: sp_categoria_get
-- Tipo: Catalog
-- Descripción: Devuelve una categoría específica por su clave
-- Generado para formulario: CategoriaMntto
-- Fecha: 2025-08-26 19:16:59

CREATE OR REPLACE FUNCTION sp_categoria_get(p_categoria SMALLINT)
RETURNS TABLE(categoria SMALLINT, descripcion VARCHAR(30))
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT categoria, descripcion FROM ta_11_categoria WHERE categoria = p_categoria;
END;
$$;