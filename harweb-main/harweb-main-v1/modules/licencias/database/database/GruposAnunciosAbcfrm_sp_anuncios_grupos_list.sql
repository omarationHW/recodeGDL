-- Stored Procedure: sp_anuncios_grupos_list
-- Tipo: Catalog
-- Descripción: Lista todos los grupos de anuncios, filtrando opcionalmente por descripción (LIKE, case-insensitive).
-- Generado para formulario: GruposAnunciosAbcfrm
-- Fecha: 2025-08-26 16:44:04

CREATE OR REPLACE FUNCTION sp_anuncios_grupos_list(p_descripcion TEXT DEFAULT '')
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT id, descripcion
    FROM anuncios_grupos
    WHERE ($1 IS NULL OR $1 = '' OR descripcion ILIKE '%' || $1 || '%')
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;