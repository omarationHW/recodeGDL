-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: gruposLicenciasfrm
-- Generado: 2025-08-27 18:23:51
-- Total SPs: 9
-- ============================================

-- SP 1/9: get_grupos_licencias
-- Tipo: Catalog
-- Descripción: Obtiene los grupos de licencias, filtrando por descripción si se proporciona.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_grupos_licencias(p_descripcion TEXT DEFAULT NULL)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE p_descripcion IS NULL OR descripcion ILIKE '%' || p_descripcion || '%'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/9: insert_grupo_licencia
-- Tipo: CRUD
-- Descripción: Inserta un nuevo grupo de licencias.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION insert_grupo_licencia(p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO lic_grupos (descripcion) VALUES (p_descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/9: update_grupo_licencia
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de licencias.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION update_grupo_licencia(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  UPDATE lic_grupos SET descripcion = p_descripcion WHERE id = p_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/9: delete_grupo_licencia
-- Tipo: CRUD
-- Descripción: Elimina un grupo de licencias por ID.
-- --------------------------------------------

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

-- ============================================

-- SP 5/9: get_licencias_disponibles
-- Tipo: Catalog
-- Descripción: Obtiene licencias vigentes que no están en el grupo, filtrando por actividad y giro.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_licencias_disponibles(p_grupo_id INTEGER, p_actividad TEXT DEFAULT NULL, p_id_giro INTEGER DEFAULT NULL)
RETURNS TABLE(
  licencia INTEGER,
  propietario TEXT,
  actividad TEXT,
  fecha_otorgamiento DATE,
  ubicacion TEXT,
  numext_ubic INTEGER,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  colonia_ubic TEXT,
  bloqueado SMALLINT,
  vigente TEXT,
  id_licencia INTEGER,
  propietarionvo TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT l.licencia, l.propietario, l.actividad, l.fecha_otorgamiento, l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic, l.colonia_ubic, l.bloqueado, l.vigente, l.id_licencia,
      TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS propietarionvo
    FROM licencias l
    WHERE l.licencia NOT IN (SELECT licencia FROM lic_detgrupo WHERE lic_grupos_id = p_grupo_id)
      AND l.vigente = 'V'
      AND (p_actividad IS NULL OR l.actividad ILIKE '%' || p_actividad || '%' OR TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) ILIKE '%' || p_actividad || '%')
      AND (p_id_giro IS NULL OR l.id_giro = p_id_giro)
    ORDER BY l.actividad;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/9: get_licencias_grupo
-- Tipo: Catalog
-- Descripción: Obtiene licencias vigentes que están en el grupo, filtrando por actividad.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_licencias_grupo(p_grupo_id INTEGER, p_actividad TEXT DEFAULT NULL)
RETURNS TABLE(
  licencia INTEGER,
  propietario TEXT,
  actividad TEXT,
  fecha_otorgamiento DATE,
  ubicacion TEXT,
  numext_ubic INTEGER,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  colonia_ubic TEXT,
  bloqueado SMALLINT,
  vigente TEXT,
  id_licencia INTEGER,
  propietarionvo TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT l.licencia, l.propietario, l.actividad, l.fecha_otorgamiento, l.ubicacion, l.numext_ubic, l.letraext_ubic, l.numint_ubic, l.letraint_ubic, l.colonia_ubic, l.bloqueado, l.vigente, l.id_licencia,
      TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) AS propietarionvo
    FROM licencias l
    WHERE l.licencia IN (SELECT licencia FROM lic_detgrupo WHERE lic_grupos_id = p_grupo_id)
      AND l.vigente = 'V'
      AND (p_actividad IS NULL OR l.actividad ILIKE '%' || p_actividad || '%' OR TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) ILIKE '%' || p_actividad || '%')
    ORDER BY l.actividad;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/9: add_licencias_to_grupo
-- Tipo: CRUD
-- Descripción: Agrega un conjunto de licencias a un grupo.
-- --------------------------------------------

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

-- ============================================

-- SP 8/9: remove_licencias_from_grupo
-- Tipo: CRUD
-- Descripción: Elimina un conjunto de licencias de un grupo.
-- --------------------------------------------

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

-- ============================================

-- SP 9/9: get_giros
-- Tipo: Catalog
-- Descripción: Obtiene los giros de tipo 'L'.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_giros()
RETURNS TABLE(id_giro INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_giro, descripcion FROM c_giros WHERE tipo = 'L' ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

