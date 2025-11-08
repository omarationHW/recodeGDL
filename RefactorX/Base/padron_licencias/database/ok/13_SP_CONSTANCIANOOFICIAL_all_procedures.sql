-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- CONSTANCIANOOFICIALFRM (13)
CREATE OR REPLACE FUNCTION SP_CONSTANCIANOOFICIAL_LIST() RETURNS TABLE(folio VARCHAR(100), solicitante VARCHAR(255), fecha DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT c.folio, c.solicitante, c.fecha FROM public.constancias_no_oficiales c; END; $$;
CREATE OR REPLACE FUNCTION SP_CONSTANCIANOOFICIAL_CREATE(p_folio VARCHAR(100), p_solicitante VARCHAR(255)) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN INSERT INTO public.constancias_no_oficiales (folio, solicitante) VALUES (p_folio, p_solicitante); RETURN QUERY SELECT TRUE, 'Constancia no oficial creada'; END; $$;