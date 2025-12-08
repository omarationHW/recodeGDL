-- Stored Procedure: sp_list_grupos_licencias
-- Tipo: Catalog
-- Descripción: Lista todos los grupos de licencias, filtrando opcionalmente por descripción (LIKE, case-insensitive).
-- Generado para formulario: GruposLicenciasAbcfrm
-- Fecha: 2025-08-27 18:20:59

CREATE OR REPLACE FUNCTION sp_list_grupos_licencias(p_descripcion TEXT DEFAULT '')
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT g.id, g.descripcion
    FROM lic_grupos g
    WHERE (p_descripcion IS NULL OR p_descripcion = '' OR g.descripcion ILIKE '%' || p_descripcion || '%')
    ORDER BY g.descripcion;
END;
$$ LANGUAGE plpgsql;