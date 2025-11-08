-- ====================================
-- STORED PROCEDURES: GRUPOS DE ANUNCIOS
-- ====================================
-- Componente: gruposAnunciosfrm.vue
-- Fecha: 2025-11-07
-- Base: padron_licencias
-- Esquema: public
--
-- TABLAS EXISTENTES UTILIZADAS:
-- - public.anun_grupos (grupos de anuncios)
-- - public.anun_detgrupo (relaciones anuncio-grupo)
-- - comun.anuncios (anuncios publicitarios)
-- - comun.licencias (licencias para obtener propietario)
-- - comun.c_giros (catálogo de giros)
-- ====================================

-- ====================================
-- 1/8: GET_GRUPOS_ANUNCIOS
-- ====================================
-- Descripción: Lista todos los grupos de anuncios con filtro opcional
-- Parámetros: p_descripcion TEXT (opcional)
-- Retorna: TABLE(id INTEGER, descripcion TEXT)

CREATE OR REPLACE FUNCTION get_grupos_anuncios(p_descripcion TEXT DEFAULT NULL)
RETURNS TABLE(id INTEGER, descripcion TEXT) AS $$
BEGIN
  RETURN QUERY
    SELECT ag.id, ag.descripcion::TEXT
    FROM public.anun_grupos ag
    WHERE p_descripcion IS NULL OR ag.descripcion ILIKE '%' || p_descripcion || '%'
    ORDER BY ag.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- 2/8: INSERT_GRUPO_ANUNCIO
-- ====================================
-- Descripción: Crea un nuevo grupo de anuncios
-- Parámetros: p_descripcion TEXT
-- Retorna: TABLE(success BOOLEAN, message TEXT, new_id INTEGER)

CREATE OR REPLACE FUNCTION insert_grupo_anuncio(p_descripcion TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT, new_id INTEGER) AS $$
DECLARE
  v_new_id INTEGER;
BEGIN
  INSERT INTO public.anun_grupos (descripcion)
  VALUES (p_descripcion)
  RETURNING id INTO v_new_id;

  RETURN QUERY SELECT TRUE::BOOLEAN, 'Grupo creado exitosamente'::TEXT, v_new_id;
EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al crear grupo: ' || SQLERRM, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- 3/8: UPDATE_GRUPO_ANUNCIO
-- ====================================
-- Descripción: Actualiza un grupo de anuncios existente
-- Parámetros: p_id INTEGER, p_descripcion TEXT
-- Retorna: TABLE(success BOOLEAN, message TEXT)

CREATE OR REPLACE FUNCTION update_grupo_anuncio(p_id INTEGER, p_descripcion TEXT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  UPDATE public.anun_grupos
  SET descripcion = p_descripcion
  WHERE id = p_id;

  IF FOUND THEN
    RETURN QUERY SELECT TRUE::BOOLEAN, 'Grupo actualizado exitosamente'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE::BOOLEAN, 'Grupo no encontrado'::TEXT;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al actualizar grupo: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- 4/8: DELETE_GRUPO_ANUNCIO
-- ====================================
-- Descripción: Elimina un grupo de anuncios
-- Parámetros: p_id INTEGER
-- Retorna: TABLE(success BOOLEAN, message TEXT)

CREATE OR REPLACE FUNCTION delete_grupo_anuncio(p_id INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  -- Primero eliminar las relaciones en anun_detgrupo
  DELETE FROM public.anun_detgrupo WHERE anun_grupos_id = p_id;

  -- Luego eliminar el grupo
  DELETE FROM public.anun_grupos WHERE id = p_id;

  IF FOUND THEN
    RETURN QUERY SELECT TRUE::BOOLEAN, 'Grupo eliminado exitosamente'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE::BOOLEAN, 'Grupo no encontrado'::TEXT;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al eliminar grupo: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- 5/8: GET_ANUNCIOS_DISPONIBLES
-- ====================================
-- Descripción: Obtiene anuncios vigentes NO asignados al grupo
-- Optimización: LEFT JOIN + DISTINCT ON (mejor performance que NOT IN)
-- Parámetros: p_grupo_id INTEGER, p_actividad TEXT, p_id_giro INTEGER
-- Retorna: TABLE con 22 columnas de información del anuncio

CREATE OR REPLACE FUNCTION get_anuncios_disponibles(
  p_grupo_id INTEGER,
  p_actividad TEXT DEFAULT NULL,
  p_id_giro INTEGER DEFAULT NULL
)
RETURNS TABLE(
  anuncio INTEGER,
  propietario TEXT,
  descripcion TEXT,
  id_giro INTEGER,
  zona SMALLINT,
  subzona SMALLINT,
  fecha_otorgamiento DATE,
  medidas1 DOUBLE PRECISION,
  medidas2 DOUBLE PRECISION,
  area_anuncio DOUBLE PRECISION,
  num_caras SMALLINT,
  ubicacion TEXT,
  numext_ubic INTEGER,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  colonia_ubic TEXT,
  vigente TEXT,
  espubic TEXT,
  bloqueado SMALLINT,
  licencia INTEGER,
  empresa INTEGER,
  propietarionvo TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ON (a.anuncio)
      a.anuncio,
      l.propietario::TEXT,
      a.descripcion::TEXT,
      a.id_giro,
      a.zona,
      a.subzona,
      a.fecha_otorgamiento,
      a.medidas1,
      a.medidas2,
      a.area_anuncio,
      a.num_caras,
      a.ubicacion::TEXT,
      a.numext_ubic,
      a.letraext_ubic::TEXT,
      a.numint_ubic::TEXT,
      a.letraint_ubic::TEXT,
      a.colonia_ubic::TEXT,
      a.vigente::TEXT,
      a.espubic::TEXT,
      a.bloqueado,
      a.licencia,
      a.empresa,
      TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, ''))::TEXT AS propietarionvo
    FROM comun.anuncios a
    LEFT JOIN public.anun_detgrupo d ON d.anuncio = a.anuncio AND d.anun_grupos_id = p_grupo_id
    LEFT JOIN comun.licencias l ON l.id_licencia = a.licencia
    WHERE a.vigente = 'V'
      AND d.anuncio IS NULL  -- Solo anuncios NO asignados al grupo
      AND (p_actividad IS NULL OR a.descripcion ILIKE '%' || p_actividad || '%')
      AND (p_id_giro IS NULL OR a.id_giro = p_id_giro)
    ORDER BY a.anuncio, a.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- 6/8: GET_ANUNCIOS_GRUPO
-- ====================================
-- Descripción: Obtiene anuncios asignados a un grupo específico
-- Optimización: INNER JOIN + DISTINCT ON
-- Parámetros: p_grupo_id INTEGER, p_actividad TEXT
-- Retorna: TABLE con 22 columnas de información del anuncio

CREATE OR REPLACE FUNCTION get_anuncios_grupo(
  p_grupo_id INTEGER,
  p_actividad TEXT DEFAULT NULL
)
RETURNS TABLE(
  anuncio INTEGER,
  propietario TEXT,
  descripcion TEXT,
  id_giro INTEGER,
  zona SMALLINT,
  subzona SMALLINT,
  fecha_otorgamiento DATE,
  medidas1 DOUBLE PRECISION,
  medidas2 DOUBLE PRECISION,
  area_anuncio DOUBLE PRECISION,
  num_caras SMALLINT,
  ubicacion TEXT,
  numext_ubic INTEGER,
  letraext_ubic TEXT,
  numint_ubic TEXT,
  letraint_ubic TEXT,
  colonia_ubic TEXT,
  vigente TEXT,
  espubic TEXT,
  bloqueado SMALLINT,
  licencia INTEGER,
  empresa INTEGER,
  propietarionvo TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT ON (a.anuncio)
      a.anuncio,
      l.propietario::TEXT,
      a.descripcion::TEXT,
      a.id_giro,
      a.zona,
      a.subzona,
      a.fecha_otorgamiento,
      a.medidas1,
      a.medidas2,
      a.area_anuncio,
      a.num_caras,
      a.ubicacion::TEXT,
      a.numext_ubic,
      a.letraext_ubic::TEXT,
      a.numint_ubic::TEXT,
      a.letraint_ubic::TEXT,
      a.colonia_ubic::TEXT,
      a.vigente::TEXT,
      a.espubic::TEXT,
      a.bloqueado,
      a.licencia,
      a.empresa,
      TRIM(COALESCE(l.primer_ap, '') || ' ' || COALESCE(l.segundo_ap, '') || ' ' || COALESCE(l.propietario, ''))::TEXT AS propietarionvo
    FROM comun.anuncios a
    INNER JOIN public.anun_detgrupo d ON d.anuncio = a.anuncio
    LEFT JOIN comun.licencias l ON l.id_licencia = a.licencia
    WHERE d.anun_grupos_id = p_grupo_id
      AND a.vigente = 'V'
      AND (p_actividad IS NULL OR a.descripcion ILIKE '%' || p_actividad || '%')
    ORDER BY a.anuncio, a.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- 7/8: ADD_ANUNCIOS_TO_GRUPO
-- ====================================
-- Descripción: Agrega múltiples anuncios a un grupo (operación batch)
-- Parámetros: p_grupo_id INTEGER, p_anuncios INTEGER[]
-- Retorna: TABLE(success BOOLEAN, message TEXT, added_count INTEGER)

CREATE OR REPLACE FUNCTION add_anuncios_to_grupo(p_grupo_id INTEGER, p_anuncios INTEGER[])
RETURNS TABLE(success BOOLEAN, message TEXT, added_count INTEGER) AS $$
DECLARE
  i INTEGER;
  cnt INTEGER := 0;
BEGIN
  FOREACH i IN ARRAY p_anuncios LOOP
    INSERT INTO public.anun_detgrupo (anun_grupos_id, anuncio)
    VALUES (p_grupo_id, i)
    ON CONFLICT DO NOTHING;

    IF FOUND THEN
      cnt := cnt + 1;
    END IF;
  END LOOP;

  RETURN QUERY SELECT TRUE::BOOLEAN, cnt || ' anuncio(s) agregado(s) al grupo'::TEXT, cnt;
EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al agregar anuncios: ' || SQLERRM, 0;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- 8/8: REMOVE_ANUNCIOS_FROM_GRUPO
-- ====================================
-- Descripción: Quita múltiples anuncios de un grupo (operación batch)
-- Parámetros: p_grupo_id INTEGER, p_anuncios INTEGER[]
-- Retorna: TABLE(success BOOLEAN, message TEXT, removed_count INTEGER)

CREATE OR REPLACE FUNCTION remove_anuncios_from_grupo(p_grupo_id INTEGER, p_anuncios INTEGER[])
RETURNS TABLE(success BOOLEAN, message TEXT, removed_count INTEGER) AS $$
DECLARE
  cnt INTEGER;
BEGIN
  DELETE FROM public.anun_detgrupo
  WHERE anun_grupos_id = p_grupo_id AND anuncio = ANY(p_anuncios);

  GET DIAGNOSTICS cnt = ROW_COUNT;

  IF cnt > 0 THEN
    RETURN QUERY SELECT TRUE::BOOLEAN, cnt || ' anuncio(s) quitado(s) del grupo'::TEXT, cnt;
  ELSE
    RETURN QUERY SELECT FALSE::BOOLEAN, 'No se encontraron anuncios para quitar'::TEXT, 0;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE::BOOLEAN, 'Error al quitar anuncios: ' || SQLERRM, 0;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- FIN DE STORED PROCEDURES
-- ====================================
-- Total: 8 SPs creados
-- Esquema: public
-- Base: padron_licencias
-- Servidor: 192.168.6.146
--
-- Para desplegar estos SPs, ejecuta este archivo SQL
-- directamente en PostgreSQL con el usuario 'refact'
-- ====================================
