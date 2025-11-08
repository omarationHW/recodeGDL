-- Stored Procedure: anuncios_grupos_delete
-- Tipo: CRUD
-- Descripción: Elimina un grupo de anuncio por ID y retorna el registro eliminado.
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-27 18:15:03

CREATE OR REPLACE FUNCTION anuncios_grupos_delete(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
DECLARE
  old_id INTEGER;
  old_desc TEXT;
BEGIN
  SELECT id, descripcion INTO old_id, old_desc FROM anuncios_grupos WHERE id = p_id;
  DELETE FROM anuncios_grupos WHERE id = p_id;
  RETURN QUERY SELECT old_id, old_desc;
END;
$$;