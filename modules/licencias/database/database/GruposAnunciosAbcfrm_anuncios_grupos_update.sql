-- Stored Procedure: anuncios_grupos_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de anuncio por ID y retorna el registro actualizado.
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-27 18:15:03

CREATE OR REPLACE FUNCTION anuncios_grupos_update(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE anuncios_grupos
  SET descripcion = UPPER(TRIM(p_descripcion))
  WHERE id = p_id;
  RETURN QUERY SELECT id, descripcion FROM anuncios_grupos WHERE id = p_id;
END;
$$;