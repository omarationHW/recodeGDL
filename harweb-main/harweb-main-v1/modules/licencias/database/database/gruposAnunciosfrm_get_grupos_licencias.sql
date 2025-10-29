-- Stored Procedure: get_grupos_licencias
-- Tipo: Catalog
-- Descripción: Obtiene los grupos de licencias filtrados por descripción.
-- Generado para formulario: gruposAnunciosfrm
-- Fecha: 2025-08-26 16:48:06

CREATE OR REPLACE FUNCTION get_grupos_licencias(filtro_descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE filtro_descripcion IS NULL OR descripcion ILIKE '%' || filtro_descripcion || '%'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;