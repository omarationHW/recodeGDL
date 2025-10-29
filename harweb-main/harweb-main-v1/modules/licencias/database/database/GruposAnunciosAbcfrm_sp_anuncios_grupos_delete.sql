-- Stored Procedure: sp_anuncios_grupos_delete
-- Tipo: CRUD
-- Descripción: Elimina un grupo de anuncios por ID y retorna el registro eliminado.
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-26 16:44:04

CREATE OR REPLACE FUNCTION sp_anuncios_grupos_delete(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
    deleted_row anuncios_grupos%ROWTYPE;
BEGIN
    SELECT * INTO deleted_row FROM anuncios_grupos WHERE id = p_id;
    DELETE FROM anuncios_grupos WHERE id = p_id;
    RETURN QUERY SELECT deleted_row.id, deleted_row.descripcion;
END;
$$ LANGUAGE plpgsql;