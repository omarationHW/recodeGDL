-- Stored Procedure: sp_get_grupo_licencia
-- Tipo: Catalog
-- Descripción: Obtiene un grupo de licencia por su ID.
-- Generado para formulario: GruposLicenciasAbcfrm
-- Fecha: 2025-08-27 18:20:59

CREATE OR REPLACE FUNCTION sp_get_grupo_licencia(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;