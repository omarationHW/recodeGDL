-- Stored Procedure: insert_grupo_anuncio
-- Tipo: CRUD
-- Descripción: Inserta un nuevo grupo de anuncios.
-- Generado para formulario: gruposAnunciosfrm
-- Fecha: 2025-08-26 16:48:06

CREATE OR REPLACE FUNCTION insert_grupo_anuncio(descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
DECLARE
  new_id INT;
BEGIN
  INSERT INTO anuncios_grupos(descripcion) VALUES (descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, descripcion FROM anuncios_grupos WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;