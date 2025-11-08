-- Stored Procedure: sp_anuncios_grupos_get
-- Tipo: Catalog
-- Descripción: Obtiene un grupo de anuncios por su ID.
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-26 16:44:04

CREATE OR REPLACE FUNCTION sp_anuncios_grupos_get(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT id, descripcion
    FROM anuncios_grupos
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;