-- ============================================
-- DEPLOY: ZonaAnuncio.vue
-- Módulo: padron_licencias
-- Total SPs: 4
-- Fecha: 2025-11-20
-- ============================================

\echo 'Desplegando ZonaAnuncio (4 SPs)...'

CREATE OR REPLACE FUNCTION public.sp_zonaanuncio_list(p_anuncio INTEGER DEFAULT NULL)
RETURNS TABLE(anuncio INTEGER, zona SMALLINT, subzona SMALLINT, recaud SMALLINT) AS $$
BEGIN
  IF p_anuncio IS NULL THEN
    RETURN QUERY SELECT anuncio, zona, subzona, recaud FROM public.anuncios_zona ORDER BY anuncio;
  ELSE
    RETURN QUERY SELECT anuncio, zona, subzona, recaud FROM public.anuncios_zona WHERE anuncio = p_anuncio;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_zonaanuncio_create(
    p_anuncio INTEGER,
    p_zona SMALLINT,
    p_subzona SMALLINT,
    p_recaud SMALLINT
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM public.anuncios_zona WHERE anuncio = p_anuncio) THEN
    RETURN QUERY SELECT FALSE, 'El anuncio ya tiene zona asignada'::TEXT;
  ELSE
    INSERT INTO public.anuncios_zona (anuncio, zona, subzona, recaud, feccap)
    VALUES (p_anuncio, p_zona, p_subzona, p_recaud, NOW());
    RETURN QUERY SELECT TRUE, 'Zona asignada exitosamente'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_zonaanuncio_update(
    p_anuncio INTEGER,
    p_zona SMALLINT,
    p_subzona SMALLINT,
    p_recaud SMALLINT
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  UPDATE public.anuncios_zona
  SET zona = p_zona, subzona = p_subzona, recaud = p_recaud, feccap = NOW()
  WHERE anuncio = p_anuncio;

  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Zona actualizada exitosamente'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE, 'Anuncio no encontrado'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_zonaanuncio_delete(p_anuncio INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  DELETE FROM public.anuncios_zona WHERE anuncio = p_anuncio;

  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Zona eliminada exitosamente'::TEXT;
  ELSE
    RETURN QUERY SELECT FALSE, 'Anuncio no encontrado'::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql;

\echo 'ZonaAnuncio completado'
