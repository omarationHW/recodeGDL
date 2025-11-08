-- Stored Procedure: remove_licencias_from_grupo
-- Tipo: CRUD
-- Descripción: Elimina un conjunto de licencias de un grupo.
-- Generado para formulario: gruposLicenciasfrm
-- Fecha: 2025-08-27 18:23:51

CREATE OR REPLACE FUNCTION remove_licencias_from_grupo(p_grupo_id INTEGER, p_licencias INTEGER[])
RETURNS TABLE(removed_count INTEGER) AS $$
DECLARE
  cnt INTEGER;
BEGIN
  DELETE FROM lic_detgrupo
  WHERE lic_grupos_id = p_grupo_id AND licencia = ANY(p_licencias);
  GET DIAGNOSTICS cnt = ROW_COUNT;
  RETURN QUERY SELECT cnt;
END;
$$ LANGUAGE plpgsql;