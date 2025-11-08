-- Stored Procedure: update_grupo_anuncio
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de anuncios.
-- Generado para formulario: gruposAnunciosfrm
-- Fecha: 2025-08-26 16:48:06

CREATE OR REPLACE FUNCTION update_grupo_anuncio(id INT, descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
BEGIN
  UPDATE anuncios_grupos SET descripcion = descripcion WHERE id = id;
  RETURN QUERY SELECT id, descripcion FROM anuncios_grupos WHERE id = id;
END;
$$ LANGUAGE plpgsql;