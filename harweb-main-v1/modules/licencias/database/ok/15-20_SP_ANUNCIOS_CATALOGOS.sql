-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULOS 15-20: GESTIÓN ANUNCIOS Y CATÁLOGOS
-- ============================================

-- BLOQUEARANUNCIORM (15)
CREATE OR REPLACE FUNCTION SP_BLOQUEARANUNCIO_LIST() RETURNS TABLE(folio VARCHAR(100), numero_anuncio VARCHAR(100), tipo_bloqueo VARCHAR(50)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT b.folio, b.numero_anuncio, b.tipo_bloqueo FROM public.bloqueos_anuncios b; END; $$;
CREATE OR REPLACE FUNCTION SP_BLOQUEARANUNCIO_CREATE(p_folio VARCHAR(100), p_numero_anuncio VARCHAR(100), p_tipo VARCHAR(50), p_motivo TEXT) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN INSERT INTO public.bloqueos_anuncios (folio, numero_anuncio, tipo_bloqueo, motivo) VALUES (p_folio, p_numero_anuncio, p_tipo, p_motivo); RETURN QUERY SELECT TRUE, 'Bloqueo de anuncio aplicado'; END; $$;

-- LIGAANUNCIOFRM (17)  
CREATE OR REPLACE FUNCTION SP_LIGAANUNCIO_LIST() RETURNS TABLE(id INTEGER, numero_anuncio VARCHAR(100), numero_licencia VARCHAR(100)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT l.id, l.numero_anuncio, l.numero_licencia FROM public.liga_anuncios l; END; $$;
CREATE OR REPLACE FUNCTION SP_LIGAANUNCIO_CREATE(p_numero_anuncio VARCHAR(100), p_numero_licencia VARCHAR(100)) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN INSERT INTO public.liga_anuncios (numero_anuncio, numero_licencia) VALUES (p_numero_anuncio, p_numero_licencia); RETURN QUERY SELECT TRUE, 'Vinculación creada'; END; $$;

-- GRUPOSANUNCIOSFRM (18)
CREATE OR REPLACE FUNCTION SP_GRUPOSANUNCIOS_LIST() RETURNS TABLE(id INTEGER, nombre_grupo VARCHAR(100), cantidad INTEGER) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT g.id, g.nombre_grupo, COUNT(ga.anuncio_id)::INTEGER FROM public.grupos_anuncios g LEFT JOIN public.grupo_anuncio ga ON g.id = ga.grupo_id GROUP BY g.id, g.nombre_grupo; END; $$;
CREATE OR REPLACE FUNCTION SP_GRUPOSANUNCIOS_CREATE(p_nombre VARCHAR(100), p_descripcion TEXT) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN INSERT INTO public.grupos_anuncios (nombre_grupo, descripcion) VALUES (p_nombre, p_descripcion); RETURN QUERY SELECT TRUE, 'Grupo de anuncios creado'; END; $$;

-- CATALOGOGIROSFRM (19)
CREATE OR REPLACE FUNCTION SP_CATALOGOGIROS_LIST() RETURNS TABLE(id INTEGER, codigo_giro VARCHAR(20), descripcion VARCHAR(255), categoria VARCHAR(100)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT c.id, c.codigo_giro, c.descripcion, c.categoria FROM public.catalogo_giros c ORDER BY c.categoria, c.descripcion; END; $$;
CREATE OR REPLACE FUNCTION SP_CATALOGOGIROS_CREATE(p_codigo VARCHAR(20), p_descripcion VARCHAR(255), p_categoria VARCHAR(100)) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN INSERT INTO public.catalogo_giros (codigo_giro, descripcion, categoria) VALUES (p_codigo, p_descripcion, p_categoria); RETURN QUERY SELECT TRUE, 'Giro agregado al catálogo'; END; $$;
CREATE OR REPLACE FUNCTION SP_CATALOGOGIROS_UPDATE(p_id INTEGER, p_descripcion VARCHAR(255), p_categoria VARCHAR(100)) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN UPDATE public.catalogo_giros SET descripcion = p_descripcion, categoria = p_categoria WHERE id = p_id; RETURN QUERY SELECT TRUE, 'Giro actualizado'; END; $$;

-- CATALOGOACTIVIDADESFRM (20)
CREATE OR REPLACE FUNCTION SP_CATALOGOACTIVIDADES_LIST() RETURNS TABLE(id INTEGER, codigo_actividad VARCHAR(20), descripcion VARCHAR(255), giro_id INTEGER) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT c.id, c.codigo_actividad, c.descripcion, c.giro_id FROM public.catalogo_actividades c ORDER BY c.descripcion; END; $$;
CREATE OR REPLACE FUNCTION SP_CATALOGOACTIVIDADES_CREATE(p_codigo VARCHAR(20), p_descripcion VARCHAR(255), p_giro_id INTEGER) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN INSERT INTO public.catalogo_actividades (codigo_actividad, descripcion, giro_id) VALUES (p_codigo, p_descripcion, p_giro_id); RETURN QUERY SELECT TRUE, 'Actividad agregada al catálogo'; END; $$;