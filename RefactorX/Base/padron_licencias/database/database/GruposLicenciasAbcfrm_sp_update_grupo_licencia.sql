-- Stored Procedure: sp_update_grupo_licencia
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de licencia por ID y retorna el registro actualizado.
-- Generado para formulario: GruposLicenciasAbcfrm
-- Fecha: 2025-08-27 18:20:59

CREATE OR REPLACE FUNCTION sp_update_grupo_licencia(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  UPDATE lic_grupos
  SET descripcion = UPPER(TRIM(p_descripcion))
  WHERE id = p_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;