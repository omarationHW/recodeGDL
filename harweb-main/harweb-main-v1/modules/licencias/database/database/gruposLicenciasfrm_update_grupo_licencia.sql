-- Stored Procedure: update_grupo_licencia
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de licencias.
-- Generado para formulario: gruposLicenciasfrm
-- Fecha: 2025-08-27 18:23:51

CREATE OR REPLACE FUNCTION update_grupo_licencia(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  UPDATE lic_grupos SET descripcion = p_descripcion WHERE id = p_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;