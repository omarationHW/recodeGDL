-- ============================================
-- FIX PARA TODOS LOS PROBLEMAS DE GRUPOS LICENCIAS
-- ============================================

-- 1. FIX: UPDATE debe retornar success/message formato estándar
CREATE OR REPLACE FUNCTION update_grupo_licencia(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  UPDATE public.lic_grupos SET descripcion = p_descripcion WHERE id = p_id;

  IF FOUND THEN
    RETURN QUERY SELECT TRUE::BOOLEAN, 'Grupo actualizado exitosamente'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE::BOOLEAN, 'Grupo no encontrado'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 2. FIX: INSERT debe retornar success/message formato estándar
CREATE OR REPLACE FUNCTION insert_grupo_licencia(p_descripcion TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT, new_id INTEGER) AS $$
DECLARE
  v_new_id INTEGER;
BEGIN
  INSERT INTO public.lic_grupos (descripcion) VALUES (p_descripcion) RETURNING id INTO v_new_id;
  RETURN QUERY SELECT TRUE::BOOLEAN, 'Grupo creado exitosamente'::TEXT, v_new_id;
END;
$$ LANGUAGE plpgsql;

-- 3. FIX: DELETE debe retornar success/message formato estándar
CREATE OR REPLACE FUNCTION delete_grupo_licencia(p_id INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  DELETE FROM public.lic_grupos WHERE id = p_id;

  IF FOUND THEN
    RETURN QUERY SELECT TRUE::BOOLEAN, 'Grupo eliminado exitosamente'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE::BOOLEAN, 'Grupo no encontrado'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 4. FIX: Agregar DISTINCT para evitar duplicados en licencias disponibles
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
  propietarionvo TEXT,
  descripcion TEXT,
  id_giro INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ON (l.licencia)
      l.licencia,
      l.propietario::TEXT,
      l.actividad::TEXT,
      l.fecha_otorgamiento,
      l.ubicacion::TEXT,
      l.numext_ubic,
      l.letraext_ubic::TEXT,
      l.numint_ubic::TEXT,
      l.letraint_ubic::TEXT,
      l.colonia_ubic::TEXT,
      l.bloqueado,
      l.vigente::TEXT,
      l.id_licencia,
      TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, ''))::TEXT AS propietarionvo,
      l.actividad::TEXT AS descripcion,
      l.id_giro
    FROM comun.licencias l
    WHERE l.licencia NOT IN (SELECT d.licencia FROM public.lic_detgrupo d WHERE d.lic_grupos_id = p_grupo_id)
      AND l.vigente = 'V'
      AND (p_actividad IS NULL OR l.actividad ILIKE '%' || p_actividad || '%' OR TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) ILIKE '%' || p_actividad || '%')
      AND (p_id_giro IS NULL OR l.id_giro = p_id_giro)
    ORDER BY l.licencia, l.actividad;
END;
$$ LANGUAGE plpgsql;

-- 5. FIX: Agregar DISTINCT para evitar duplicados en licencias del grupo
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
  propietarionvo TEXT,
  descripcion TEXT,
  id_giro INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ON (l.licencia)
      l.licencia,
      l.propietario::TEXT,
      l.actividad::TEXT,
      l.fecha_otorgamiento,
      l.ubicacion::TEXT,
      l.numext_ubic,
      l.letraext_ubic::TEXT,
      l.numint_ubic::TEXT,
      l.letraint_ubic::TEXT,
      l.colonia_ubic::TEXT,
      l.bloqueado,
      l.vigente::TEXT,
      l.id_licencia,
      TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, ''))::TEXT AS propietarionvo,
      l.actividad::TEXT AS descripcion,
      l.id_giro
    FROM comun.licencias l
    WHERE l.licencia IN (SELECT d.licencia FROM public.lic_detgrupo d WHERE d.lic_grupos_id = p_grupo_id)
      AND l.vigente = 'V'
      AND (p_actividad IS NULL OR l.actividad ILIKE '%' || p_actividad || '%' OR TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, '')) ILIKE '%' || p_actividad || '%')
    ORDER BY l.licencia, l.actividad;
END;
$$ LANGUAGE plpgsql;

-- 6. FIX: ADD con mejor retorno y manejo correcto del array
CREATE OR REPLACE FUNCTION add_licencias_to_grupo(p_grupo_id INTEGER, p_licencias INTEGER[])
RETURNS TABLE(success BOOLEAN, message TEXT, added_count INTEGER) AS $$
DECLARE
  i INTEGER;
  cnt INTEGER := 0;
BEGIN
  FOREACH i IN ARRAY p_licencias LOOP
    INSERT INTO public.lic_detgrupo (lic_grupos_id, licencia)
    VALUES (p_grupo_id, i)
    ON CONFLICT DO NOTHING;
    GET DIAGNOSTICS cnt = ROW_COUNT;
    IF cnt > 0 THEN
      cnt := cnt + 1;
    END IF;
  END LOOP;

  RETURN QUERY SELECT TRUE::BOOLEAN, cnt || ' licencia(s) agregada(s) al grupo'::TEXT, cnt;
END;
$$ LANGUAGE plpgsql;

-- 7. FIX: REMOVE con mejor retorno
CREATE OR REPLACE FUNCTION remove_licencias_from_grupo(p_grupo_id INTEGER, p_licencias INTEGER[])
RETURNS TABLE(success BOOLEAN, message TEXT, removed_count INTEGER) AS $$
DECLARE
  cnt INTEGER;
BEGIN
  DELETE FROM public.lic_detgrupo
  WHERE lic_grupos_id = p_grupo_id AND licencia = ANY(p_licencias);

  GET DIAGNOSTICS cnt = ROW_COUNT;

  IF cnt > 0 THEN
    RETURN QUERY SELECT TRUE::BOOLEAN, cnt || ' licencia(s) quitada(s) del grupo'::TEXT, cnt;
  ELSE
    RETURN QUERY SELECT FALSE::BOOLEAN, 'No se encontraron licencias para quitar'::TEXT, 0;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 8. FIX: GET_GIROS con esquema correcto
CREATE OR REPLACE FUNCTION get_giros()
RETURNS TABLE(id_giro INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT g.id_giro, g.descripcion::TEXT
    FROM comun.c_giros g
    WHERE g.tipo = 'L'
    ORDER BY g.descripcion;
END;
$$ LANGUAGE plpgsql;
