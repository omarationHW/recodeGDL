-- Stored Procedure: sp_anuncios_grupos_insert
-- Tipo: CRUD
-- Descripción: Inserta un nuevo grupo de anuncios y retorna el registro insertado.
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-26 16:44:04

CREATE OR REPLACE FUNCTION sp_anuncios_grupos_insert(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO anuncios_grupos (descripcion)
    VALUES (p_descripcion)
    RETURNING id INTO new_id;
    RETURN QUERY SELECT id, descripcion FROM anuncios_grupos WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;