-- Stored Procedure: sp_delete_grupo_licencia
-- Tipo: CRUD
-- Descripción: Elimina un grupo de licencia por ID y retorna el ID eliminado.
-- Generado para formulario: GruposLicenciasAbcfrm
-- Fecha: 2025-08-27 18:20:59

CREATE OR REPLACE FUNCTION sp_delete_grupo_licencia(p_id INTEGER)
RETURNS TABLE(id INTEGER) AS $$
BEGIN
  DELETE FROM lic_grupos WHERE id = p_id RETURNING id;
END;
$$ LANGUAGE plpgsql;