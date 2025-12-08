-- ============================================
-- DEPLOY: ZonaLicencia.vue
-- Módulo: padron_licencias
-- Total SPs: 5
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando ZonaLicencia (5 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_get_licencia(p_licencia INTEGER)
RETURNS TABLE(
    licencia INTEGER, empresa INTEGER, zona SMALLINT, subzona SMALLINT,
    recaud SMALLINT, propietario VARCHAR, rfc VARCHAR, ubicacion VARCHAR,
    numext_ubic INTEGER, colonia_ubic VARCHAR, vigente VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT l.licencia, l.empresa, l.zona, l.subzona, l.recaud,
         e.propietario, e.rfc, e.ubicacion, e.numext_ubic, e.colonia_ubic, l.vigente
  FROM comun.licencias l
  JOIN comun.empresas e ON l.empresa = e.empresa
  WHERE l.licencia = p_licencia;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_get_zonas(p_recaud INTEGER)
RETURNS TABLE(cvezona SMALLINT, zona VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT z.cvezona, z.zona, z.cvezona || ' - ' || z.zona AS descripcion
  FROM public.c_zonas z
  WHERE z.cvezona IN (SELECT zona FROM comun.c_zonayrec WHERE rec = p_recaud)
  ORDER BY z.cvezona;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_get_subzonas(p_cvezona INTEGER, p_recaud INTEGER)
RETURNS TABLE(cvesubzona INTEGER, descsubzon VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT s.cvesubzona, s.descsubzon, s.cvesubzona || ' - ' || s.descsubzon AS descripcion
  FROM public.c_subzonas s
  WHERE s.cvezona = p_cvezona
    AND s.cvesubzona IN (SELECT subzona FROM comun.c_zonayrec WHERE rec = p_recaud AND zona = s.cvezona)
  ORDER BY s.cvesubzona;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_get_recaudadoras()
RETURNS TABLE(recaud SMALLINT, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY
  SELECT recaud, descripcion
  FROM comun.c_recaud
  WHERE recaud <= 5
  ORDER BY recaud;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_save_licencias_zona(
    p_licencia INTEGER,
    p_zona SMALLINT,
    p_subzona SMALLINT,
    p_recaud SMALLINT
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.licencias_zona WHERE licencia = p_licencia) THEN
    UPDATE public.licencias_zona
    SET zona = p_zona, subzona = p_subzona, recaud = p_recaud, feccap = NOW()
    WHERE licencia = p_licencia;
    RETURN QUERY SELECT TRUE, 'Zona actualizada exitosamente'::TEXT;
  ELSE
    INSERT INTO public.licencias_zona (licencia, zona, subzona, recaud, feccap)
    VALUES (p_licencia, p_zona, p_subzona, p_recaud, NOW());
    RETURN QUERY SELECT TRUE, 'Zona asignada exitosamente'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'ZonaLicencia completado'
