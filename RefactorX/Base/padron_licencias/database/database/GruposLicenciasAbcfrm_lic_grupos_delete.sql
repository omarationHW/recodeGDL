-- Stored Procedure: lic_grupos_delete
-- Tipo: CRUD
-- Descripción: Elimina un grupo de licencias por ID y retorna el registro eliminado.
-- Generado para formulario: GruposLicenciasAbcfrm
-- Fecha: 2025-08-26 16:50:25

CREATE OR REPLACE FUNCTION lic_grupos_delete(p_id INTEGER)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
DECLARE
  old_id INTEGER;
  old_desc TEXT;
BEGIN
  SELECT id, descripcion INTO old_id, old_desc FROM lic_grupos WHERE id = p_id;
  DELETE FROM lic_grupos WHERE id = p_id;
  RETURN QUERY SELECT old_id, old_desc;
END;
$$;