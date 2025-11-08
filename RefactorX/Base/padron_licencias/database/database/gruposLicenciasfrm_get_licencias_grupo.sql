-- Stored Procedure: get_licencias_grupo
-- Tipo: Catalog
-- Descripción: Obtiene licencias vigentes que están en el grupo, filtrando por actividad.
-- Generado para formulario: gruposLicenciasfrm
-- Fecha: 2025-08-27 18:23:51

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