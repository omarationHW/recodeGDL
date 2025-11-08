-- Stored Procedure: lic_grupos_list
-- Tipo: Catalog
-- Descripción: Lista todos los grupos de licencias, con filtro opcional por descripción (LIKE, insensible a mayúsculas).
-- Generado para formulario: GruposLicenciasAbcfrm
-- Fecha: 2025-08-26 16:50:25

CREATE OR REPLACE FUNCTION lic_grupos_list(descripcion TEXT DEFAULT '')
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE descripcion ILIKE '%' || descripcion || '%'
    ORDER BY descripcion;
END;
$$;