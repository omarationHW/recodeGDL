-- Stored Procedure: get_grupos_licencias
-- Tipo: Catalog
-- Descripción: Obtiene los grupos de licencias, filtrando por descripción si se proporciona.
-- Generado para formulario: gruposLicenciasfrm
-- Fecha: 2025-08-27 18:23:51

CREATE OR REPLACE FUNCTION get_grupos_licencias(p_descripcion TEXT DEFAULT NULL)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE p_descripcion IS NULL OR descripcion ILIKE '%' || p_descripcion || '%'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;