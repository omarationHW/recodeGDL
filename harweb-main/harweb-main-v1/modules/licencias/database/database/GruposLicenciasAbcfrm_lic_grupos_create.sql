-- Stored Procedure: lic_grupos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo grupo de licencias y retorna el registro insertado.
-- Generado para formulario: GruposLicenciasAbcfrm
-- Fecha: 2025-08-26 16:50:25

CREATE OR REPLACE FUNCTION lic_grupos_create(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT)
LANGUAGE plpgsql AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO lic_grupos (descripcion)
  VALUES (UPPER(TRIM(p_descripcion)))
  RETURNING id, descripcion INTO new_id, descripcion;
  RETURN QUERY SELECT new_id, descripcion FROM lic_grupos WHERE id = new_id;
END;
$$;