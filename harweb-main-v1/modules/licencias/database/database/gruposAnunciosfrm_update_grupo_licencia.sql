-- Stored Procedure: update_grupo_licencia
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de licencias.
-- Generado para formulario: gruposAnunciosfrm
-- Fecha: 2025-08-26 16:48:06

CREATE OR REPLACE FUNCTION update_grupo_licencia(id INT, descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
BEGIN
  UPDATE lic_grupos SET descripcion = descripcion WHERE id = id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = id;
END;
$$ LANGUAGE plpgsql;