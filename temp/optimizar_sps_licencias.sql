-- ============================================
-- SPs OPTIMIZADOS PARA GRUPOS LICENCIAS
-- Con LEFT JOIN en lugar de NOT IN (más rápido)
-- Con LIMIT para cargar menos datos inicialmente
-- ============================================

-- 1. Crear índices si no existen
CREATE INDEX IF NOT EXISTS idx_lic_detgrupo_grupos_id ON public.lic_detgrupo(lic_grupos_id);
CREATE INDEX IF NOT EXISTS idx_lic_detgrupo_licencia ON public.lic_detgrupo(licencia);
CREATE INDEX IF NOT EXISTS idx_lic_detgrupo_composite ON public.lic_detgrupo(lic_grupos_id, licencia);
CREATE INDEX IF NOT EXISTS idx_licencias_vigente ON comun.licencias(vigente);
CREATE INDEX IF NOT EXISTS idx_licencias_id_giro ON comun.licencias(id_giro);

-- 2. SP OPTIMIZADO: get_licencias_disponibles con LEFT JOIN
CREATE OR REPLACE FUNCTION get_licencias_disponibles(
    p_grupo_id INTEGER,
    p_actividad TEXT DEFAULT NULL,
    p_id_giro INTEGER DEFAULT NULL,
    p_limit INTEGER DEFAULT 500  -- Límite por defecto de 500
)
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
    LEFT JOIN public.lic_detgrupo d ON d.licencia = l.licencia AND d.lic_grupos_id = p_grupo_id
    WHERE l.vigente = 'V'
      AND d.licencia IS NULL  -- Solo las que NO están en el grupo
      AND (p_actividad IS NULL OR l.actividad ILIKE '%' || p_actividad || '%')
      AND (p_id_giro IS NULL OR l.id_giro = p_id_giro)
    ORDER BY l.licencia, l.actividad
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- 3. SP OPTIMIZADO: get_licencias_grupo con INNER JOIN
CREATE OR REPLACE FUNCTION get_licencias_grupo(
    p_grupo_id INTEGER,
    p_actividad TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 500  -- Límite por defecto de 500
)
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
    INNER JOIN public.lic_detgrupo d ON d.licencia = l.licencia
    WHERE d.lic_grupos_id = p_grupo_id
      AND l.vigente = 'V'
      AND (p_actividad IS NULL OR l.actividad ILIKE '%' || p_actividad || '%')
    ORDER BY l.licencia, l.actividad
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- 4. Verificar que se crearon los índices
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname IN ('public', 'comun')
  AND tablename IN ('lic_detgrupo', 'licencias')
ORDER BY tablename, indexname;
