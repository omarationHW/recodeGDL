-- Stored Procedure: sp_anuncios_grupos_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de anuncios por ID y retorna el registro actualizado.
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-26 16:44:04

CREATE OR REPLACE FUNCTION sp_anuncios_grupos_update(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
    UPDATE anuncios_grupos
    SET descripcion = p_descripcion
    WHERE id = p_id;
    RETURN QUERY SELECT id, descripcion FROM anuncios_grupos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;