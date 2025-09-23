-- Stored Procedure: anuncios_grupos_insert
-- Tipo: CRUD
-- Descripción: Inserta un nuevo grupo de anuncio y retorna el registro insertado.
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-27 18:15:03

CREATE OR REPLACE FUNCTION anuncios_grupos_insert(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO anuncios_grupos(descripcion)
  VALUES (UPPER(TRIM(p_descripcion)))
  RETURNING id, descripcion INTO new_id, p_descripcion;
  RETURN QUERY SELECT new_id, p_descripcion;
END;
$$;