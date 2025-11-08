-- Stored Procedure: anuncios_grupos_list
-- Tipo: Catalog
-- Descripción: Lista todos los grupos de anuncios, con filtro opcional por descripción.
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-27 18:15:03

CREATE OR REPLACE FUNCTION anuncios_grupos_list(p_descripcion TEXT DEFAULT NULL)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM anuncios_grupos
    WHERE (p_descripcion IS NULL OR descripcion ILIKE '%' || p_descripcion || '%')
    ORDER BY descripcion;
END;
$$;