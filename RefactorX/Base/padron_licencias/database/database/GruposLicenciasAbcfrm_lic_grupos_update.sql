-- Stored Procedure: lic_grupos_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de licencias por ID y retorna el registro actualizado.
-- Generado para formulario: GruposLicenciasAbcfrm
-- Fecha: 2025-08-26 16:50:25

CREATE OR REPLACE FUNCTION lic_grupos_update(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE lic_grupos
  SET descripcion = UPPER(TRIM(p_descripcion))
  WHERE id = p_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = p_id;
END;
$$;