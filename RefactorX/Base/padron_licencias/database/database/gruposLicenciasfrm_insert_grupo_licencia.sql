-- Stored Procedure: insert_grupo_licencia
-- Tipo: CRUD
-- Descripción: Inserta un nuevo grupo de licencias.
-- Generado para formulario: gruposLicenciasfrm
-- Fecha: 2025-08-27 18:23:51

CREATE OR REPLACE FUNCTION insert_grupo_licencia(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO lic_grupos (descripcion) VALUES (p_descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;