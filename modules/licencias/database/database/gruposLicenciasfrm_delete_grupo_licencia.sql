-- Stored Procedure: delete_grupo_licencia
-- Tipo: CRUD
-- Descripción: Elimina un grupo de licencias por ID.
-- Generado para formulario: gruposLicenciasfrm
-- Fecha: 2025-08-27 18:23:51

CREATE OR REPLACE FUNCTION delete_grupo_licencia(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
  old_row lic_grupos%ROWTYPE;
BEGIN
  SELECT * INTO old_row FROM lic_grupos WHERE id = p_id;
  DELETE FROM lic_grupos WHERE id = p_id;
  RETURN QUERY SELECT old_row.id, old_row.descripcion;
END;
$$ LANGUAGE plpgsql;