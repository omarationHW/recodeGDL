-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: gruposAnunciosfrm
-- Generado: 2025-08-26 16:48:06
-- Total SPs: 11
-- ============================================

-- SP 1/11: get_grupos_anuncios
-- Tipo: Catalog
-- Descripción: Obtiene los grupos de anuncios filtrados por descripción (LIKE).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_grupos_anuncios(filtro_descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM anuncios_grupos
    WHERE filtro_descripcion IS NULL OR descripcion ILIKE '%' || filtro_descripcion || '%'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/11: insert_grupo_anuncio
-- Tipo: CRUD
-- Descripción: Inserta un nuevo grupo de anuncios.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION insert_grupo_anuncio(descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
DECLARE
  new_id INT;
BEGIN
  INSERT INTO anuncios_grupos(descripcion) VALUES (descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, descripcion FROM anuncios_grupos WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/11: update_grupo_anuncio
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de anuncios.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION update_grupo_anuncio(id INT, descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
BEGIN
  UPDATE anuncios_grupos SET descripcion = descripcion WHERE id = id;
  RETURN QUERY SELECT id, descripcion FROM anuncios_grupos WHERE id = id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/11: get_anuncios_disponibles
-- Tipo: Catalog
-- Descripción: Obtiene los anuncios vigentes que NO están en el grupo, filtrados por giro y/o texto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_anuncios_disponibles(grupo_id INT, filtro TEXT, giro_id INT)
RETURNS TABLE(
  anuncio INT,
  propietario TEXT,
  descripcion TEXT,
  id_giro INT,
  zona SMALLINT,
  subzona SMALLINT,
  fecha_otorgamiento DATE,
  medidas1 FLOAT,
  medidas2 FLOAT,
  area_anuncio FLOAT,
  num_caras SMALLINT,
  ubicacion TEXT,
  numext_ubic INT,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  colonia_ubic TEXT,
  vigente TEXT,
  espubic TEXT,
  bloqueado SMALLINT,
  licencia INT,
  empresa INT,
  propietarionvo TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.anuncio, l.propietario, a.descripcion, a.id_giro, a.zona, a.subzona, a.fecha_otorgamiento, a.medidas1, a.medidas2, a.area_anuncio, a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic, a.colonia_ubic, a.vigente, a.espubic, a.bloqueado, a.licencia, a.empresa,
      TRIM(COALESCE(l.primer_ap,'') || ' ' || COALESCE(l.segundo_ap,'') || ' ' || COALESCE(l.propietario,'')) AS propietarionvo
    FROM anuncios a
    INNER JOIN licencias l ON l.id_licencia = a.licencia
    INNER JOIN c_giros c ON c.id_giro = a.id_giro
    WHERE a.anuncio NOT IN (
      SELECT anuncio FROM anuncios_detgrupo WHERE anuncios_grupos_id = grupo_id
    )
    AND a.vigente = 'V'
    AND (
      filtro IS NULL OR filtro = '' OR
      c.descripcion ILIKE '%' || filtro || '%' OR
      TRIM(COALESCE(l.primer_ap,'') || ' ' || COALESCE(l.segundo_ap,'') || ' ' || COALESCE(l.propietario,'')) ILIKE '%' || filtro || '%'
    )
    AND (giro_id IS NULL OR a.id_giro = giro_id);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/11: get_anuncios_en_grupo
-- Tipo: Catalog
-- Descripción: Obtiene los anuncios vigentes que están en el grupo, filtrados por texto.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_anuncios_en_grupo(grupo_id INT, filtro TEXT)
RETURNS TABLE(
  anuncio INT,
  propietario TEXT,
  descripcion TEXT,
  id_giro INT,
  zona SMALLINT,
  subzona SMALLINT,
  fecha_otorgamiento DATE,
  medidas1 FLOAT,
  medidas2 FLOAT,
  area_anuncio FLOAT,
  num_caras SMALLINT,
  ubicacion TEXT,
  numext_ubic INT,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  colonia_ubic TEXT,
  vigente TEXT,
  espubic TEXT,
  bloqueado SMALLINT,
  licencia INT,
  empresa INT,
  propietarionvo TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.anuncio, l.propietario, a.descripcion, a.id_giro, a.zona, a.subzona, a.fecha_otorgamiento, a.medidas1, a.medidas2, a.area_anuncio, a.num_caras, a.ubicacion, a.numext_ubic, a.letraext_ubic, a.numint_ubic, a.letraint_ubic, a.colonia_ubic, a.vigente, a.espubic, a.bloqueado, a.licencia, a.empresa,
      TRIM(COALESCE(l.primer_ap,'') || ' ' || COALESCE(l.segundo_ap,'') || ' ' || COALESCE(l.propietario,'')) AS propietarionvo
    FROM anuncios a
    INNER JOIN licencias l ON l.id_licencia = a.licencia
    INNER JOIN c_giros c ON c.id_giro = a.id_giro
    WHERE a.anuncio IN (
      SELECT anuncio FROM anuncios_detgrupo WHERE anuncios_grupos_id = grupo_id
    )
    AND a.vigente = 'V'
    AND (
      filtro IS NULL OR filtro = '' OR
      c.descripcion ILIKE '%' || filtro || '%' OR
      TRIM(COALESCE(l.primer_ap,'') || ' ' || COALESCE(l.segundo_ap,'') || ' ' || COALESCE(l.propietario,'')) ILIKE '%' || filtro || '%'
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/11: add_anuncios_to_grupo
-- Tipo: CRUD
-- Descripción: Agrega una lista de anuncios a un grupo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION add_anuncios_to_grupo(grupo_id INT, anuncios_json TEXT)
RETURNS TABLE(anuncio INT) AS $$
DECLARE
  anuncios INT[];
  i INT;
BEGIN
  SELECT array_agg((value::INT)) INTO anuncios FROM json_array_elements_text(anuncios_json::json);
  IF anuncios IS NOT NULL THEN
    FOREACH i IN ARRAY anuncios LOOP
      INSERT INTO anuncios_detgrupo(anuncios_grupos_id, anuncio)
      VALUES (grupo_id, i)
      ON CONFLICT DO NOTHING;
      RETURN NEXT i;
    END LOOP;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/11: remove_anuncios_from_grupo
-- Tipo: CRUD
-- Descripción: Elimina una lista de anuncios de un grupo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION remove_anuncios_from_grupo(grupo_id INT, anuncios_json TEXT)
RETURNS TABLE(anuncio INT) AS $$
DECLARE
  anuncios INT[];
  i INT;
BEGIN
  SELECT array_agg((value::INT)) INTO anuncios FROM json_array_elements_text(anuncios_json::json);
  IF anuncios IS NOT NULL THEN
    FOREACH i IN ARRAY anuncios LOOP
      DELETE FROM anuncios_detgrupo WHERE anuncios_grupos_id = grupo_id AND anuncio = i;
      RETURN NEXT i;
    END LOOP;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/11: get_giros
-- Tipo: Catalog
-- Descripción: Obtiene los giros activos (tipo = 'A').
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_giros()
RETURNS TABLE(id_giro INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY SELECT id_giro, descripcion FROM c_giros WHERE tipo = 'A' ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 9/11: get_grupos_licencias
-- Tipo: Catalog
-- Descripción: Obtiene los grupos de licencias filtrados por descripción.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_grupos_licencias(filtro_descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT id, descripcion
    FROM lic_grupos
    WHERE filtro_descripcion IS NULL OR descripcion ILIKE '%' || filtro_descripcion || '%'
    ORDER BY descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 10/11: insert_grupo_licencia
-- Tipo: CRUD
-- Descripción: Inserta un nuevo grupo de licencias.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION insert_grupo_licencia(descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
DECLARE
  new_id INT;
BEGIN
  INSERT INTO lic_grupos(descripcion) VALUES (descripcion) RETURNING id INTO new_id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 11/11: update_grupo_licencia
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un grupo de licencias.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION update_grupo_licencia(id INT, descripcion TEXT)
RETURNS TABLE(id INT, descripcion TEXT) AS $$
BEGIN
  UPDATE lic_grupos SET descripcion = descripcion WHERE id = id;
  RETURN QUERY SELECT id, descripcion FROM lic_grupos WHERE id = id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

