-- Stored Procedure: anuncios_grupos_get
-- Tipo: Catalog
-- Descripción: Obtiene un grupo de anuncio por su ID.
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-27 18:15:03

CREATE OR REPLACE FUNCTION anuncios_grupos_get(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM anuncios_grupos
    WHERE id = p_id;
END;
$$;