-- Stored Procedure: add_licencias_to_grupo
-- Tipo: CRUD
-- Descripción: Agrega un conjunto de licencias a un grupo.
-- Generado para formulario: gruposLicenciasfrm
-- Fecha: 2025-08-27 18:23:51

CREATE OR REPLACE FUNCTION add_licencias_to_grupo(p_grupo_id INTEGER, p_licencias INTEGER[])
RETURNS TABLE(added_count INTEGER) AS $$
DECLARE
  i INTEGER;
  cnt INTEGER := 0;
BEGIN
  FOREACH i IN ARRAY p_licencias LOOP
    INSERT INTO lic_detgrupo (lic_grupos_id, licencia)
    VALUES (p_grupo_id, i)
    ON CONFLICT DO NOTHING;
    cnt := cnt + 1;
  END LOOP;
  RETURN QUERY SELECT cnt;
END;
$$ LANGUAGE plpgsql;