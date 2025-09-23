-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- BAJAANUNCIOFRM (14)
CREATE OR REPLACE FUNCTION SP_BAJAANUNCIO_LIST() RETURNS TABLE(folio VARCHAR(100), numero_anuncio VARCHAR(100), estado VARCHAR(30)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT ba.folio_baja, ba.numero_anuncio, ba.estado FROM public.bajas_anuncios ba; END; $$;
CREATE OR REPLACE FUNCTION SP_BAJAANUNCIO_CREATE(p_folio VARCHAR(100), p_numero_anuncio VARCHAR(100), p_motivo TEXT) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN INSERT INTO public.bajas_anuncios (folio_baja, numero_anuncio, motivo) VALUES (p_folio, p_numero_anuncio, p_motivo); RETURN QUERY SELECT TRUE, 'Baja de anuncio registrada'; END; $$;
CREATE OR REPLACE FUNCTION SP_BAJAANUNCIO_APROBAR(p_folio VARCHAR(100)) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN UPDATE public.bajas_anuncios SET estado = 'APROBADA' WHERE folio_baja = p_folio; RETURN QUERY SELECT TRUE, 'Baja aprobada'; END; $$;