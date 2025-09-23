-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULOS 41-60: DOCUMENTOS E IMPRESIONES
-- ============================================

-- REPDOC (41)
CREATE OR REPLACE FUNCTION SP_REPDOC_LIST() RETURNS TABLE(id INTEGER, nombre_documento VARCHAR(255), tipo_documento VARCHAR(50), fecha_creacion DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT d.id, d.nombre_documento, d.tipo_documento, d.fecha_creacion FROM public.documentos d ORDER BY d.fecha_creacion DESC; END; $$;

-- DOCTOSFRM (42)
CREATE OR REPLACE FUNCTION SP_DOCTOS_LIST() RETURNS TABLE(id INTEGER, codigo_documento VARCHAR(20), descripcion VARCHAR(255), obligatorio BOOLEAN) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT d.id, d.codigo_documento, d.descripcion, d.obligatorio FROM public.catalogo_documentos d ORDER BY d.descripcion; END; $$;

-- CERTIFICACIONESFRM (43)
CREATE OR REPLACE FUNCTION SP_CERTIFICACIONES_LIST() RETURNS TABLE(folio_certificacion VARCHAR(100), numero_licencia VARCHAR(100), tipo_certificacion VARCHAR(50), fecha_expedicion DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT c.folio_certificacion, c.numero_licencia, c.tipo_certificacion, c.fecha_expedicion FROM public.certificaciones c ORDER BY c.fecha_expedicion DESC; END; $$;

-- DICTAMENFRM (44)
CREATE OR REPLACE FUNCTION SP_DICTAMEN_LIST() RETURNS TABLE(folio_dictamen VARCHAR(100), numero_tramite VARCHAR(100), tipo_dictamen VARCHAR(50), resultado VARCHAR(20)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT d.folio_dictamen, d.numero_tramite, d.tipo_dictamen, d.resultado FROM public.dictamenes d ORDER BY d.fecha_dictamen DESC; END; $$;

-- DICTAMENUSODESUELO (45)
CREATE OR REPLACE FUNCTION SP_DICTAMENUSO_LIST() RETURNS TABLE(folio_dictamen VARCHAR(100), cuenta_predial VARCHAR(50), uso_solicitado VARCHAR(100), dictamen_resultado VARCHAR(20)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT d.folio_dictamen, d.cuenta_predial, d.uso_solicitado, d.dictamen_resultado FROM public.dictamenes_uso_suelo d ORDER BY d.fecha_dictamen DESC; END; $$;

-- RESPONSIVAFRM (46)
CREATE OR REPLACE FUNCTION SP_RESPONSIVA_LIST() RETURNS TABLE(folio_responsiva VARCHAR(100), responsable VARCHAR(255), tipo_responsiva VARCHAR(50), fecha_firma DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT r.folio_responsiva, r.responsable, r.tipo_responsiva, r.fecha_firma FROM public.responsivas r ORDER BY r.fecha_firma DESC; END; $$;

-- FORMATOSECOLOGIAFRM (47)
CREATE OR REPLACE FUNCTION SP_FORMATOSECOLOGIA_LIST() RETURNS TABLE(folio_formato VARCHAR(100), numero_licencia VARCHAR(100), tipo_formato VARCHAR(50), estado_tramite VARCHAR(30)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT f.folio_formato, f.numero_licencia, f.tipo_formato, f.estado_tramite FROM public.formatos_ecologia f ORDER BY f.fecha_presentacion DESC; END; $$;

-- GESTIONHOLOGRAMASFRM (48)
CREATE OR REPLACE FUNCTION SP_GESTIONHOLOGRAMAS_LIST() RETURNS TABLE(codigo_holograma VARCHAR(50), numero_licencia VARCHAR(100), estado_holograma VARCHAR(30), fecha_asignacion DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT h.codigo_holograma, h.numero_licencia, h.estado_holograma, h.fecha_asignacion FROM public.hologramas h ORDER BY h.fecha_asignacion DESC; END; $$;

-- PROPHOLOGRAMASFRM (49)
CREATE OR REPLACE FUNCTION SP_PROPHOLOGRAMAS_LIST() RETURNS TABLE(lote_hologramas VARCHAR(50), cantidad_hologramas INTEGER, fecha_recepcion DATE, estado_lote VARCHAR(30)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT p.lote_hologramas, p.cantidad_hologramas, p.fecha_recepcion, p.estado_lote FROM public.lotes_hologramas p ORDER BY p.fecha_recepcion DESC; END; $$;

-- IMPRECIBOFRM (50)
CREATE OR REPLACE FUNCTION SP_IMPRECIBO_GENERATE(p_numero_recibo VARCHAR(100)) RETURNS TABLE(numero_recibo VARCHAR(100), concepto TEXT, monto NUMERIC(10,2), fecha_pago DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT r.numero_recibo, r.concepto, r.monto, r.fecha_pago FROM public.recibos r WHERE r.numero_recibo = p_numero_recibo; END; $$;

-- IMPOFICIOFRM (51)
CREATE OR REPLACE FUNCTION SP_IMPOFICIO_GENERATE(p_folio_oficio VARCHAR(100)) RETURNS TABLE(folio_oficio VARCHAR(100), destinatario VARCHAR(255), asunto TEXT, contenido TEXT) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT o.folio_oficio, o.destinatario, o.asunto, o.contenido FROM public.oficios o WHERE o.folio_oficio = p_folio_oficio; END; $$;

-- IMPLICENCIAREGLAMENTADAFRM (52)
CREATE OR REPLACE FUNCTION SP_IMPLICENCIAREGLAMENTADA_GENERATE(p_numero_licencia VARCHAR(100)) RETURNS TABLE(numero_licencia VARCHAR(100), propietario VARCHAR(255), direccion TEXT, giro VARCHAR(255), vigencia_desde DATE, vigencia_hasta DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT l.numero_licencia, l.propietario, l.direccion, l.giro, l.fecha_expedicion, l.fecha_vencimiento FROM public.licencias_comerciales l WHERE l.numero_licencia = p_numero_licencia AND l.tipo_licencia = 'REGLAMENTADA'; END; $$;

-- FRMIMPLICENCIAREGLAMENTADA (53)
CREATE OR REPLACE FUNCTION SP_FRMIMPLICENCIAREGLAMENTADA_DATA(p_numero_licencia VARCHAR(100)) RETURNS TABLE(datos_licencia TEXT, requisitos_cumplidos TEXT, observaciones TEXT) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT l.datos_completos, l.requisitos_cumplidos, l.observaciones FROM public.licencias_reglamentadas l WHERE l.numero_licencia = p_numero_licencia; END; $$;

-- IMPSOLINSPECCIONFRM (54)
CREATE OR REPLACE FUNCTION SP_IMPSOLINSPECCION_GENERATE(p_folio_solicitud VARCHAR(100)) RETURNS TABLE(folio_solicitud VARCHAR(100), numero_licencia VARCHAR(100), tipo_inspeccion VARCHAR(50), fecha_programada DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT s.folio_solicitud, s.numero_licencia, s.tipo_inspeccion, s.fecha_programada FROM public.solicitudes_inspeccion s WHERE s.folio_solicitud = p_folio_solicitud; END; $$;

-- CONSLIC400FRM (55)
CREATE OR REPLACE FUNCTION SP_CONSLIC400_LIST() RETURNS TABLE(numero_licencia VARCHAR(100), propietario VARCHAR(255), giro VARCHAR(255), superficie NUMERIC(10,2)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT l.numero_licencia, l.propietario, l.giro, l.superficie_autorizada FROM public.licencias_comerciales l WHERE l.superficie_autorizada >= 400 ORDER BY l.superficie_autorizada DESC; END; $$;

-- CONSANUN400FRM (56)
CREATE OR REPLACE FUNCTION SP_CONSANUN400_LIST() RETURNS TABLE(numero_anuncio VARCHAR(100), propietario VARCHAR(255), dimensiones VARCHAR(100), superficie_calculo NUMERIC(8,2)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT a.numero_anuncio, a.propietario, a.dimensiones, (CAST(SPLIT_PART(a.dimensiones, 'x', 1) AS NUMERIC) * CAST(SPLIT_PART(SPLIT_PART(a.dimensiones, 'x', 2), ' ', 1) AS NUMERIC)) as superficie FROM public.anuncios_publicitarios a WHERE (CAST(SPLIT_PART(a.dimensiones, 'x', 1) AS NUMERIC) * CAST(SPLIT_PART(SPLIT_PART(a.dimensiones, 'x', 2), ' ', 1) AS NUMERIC)) >= 400; END; $$;

-- GIROSDCONADEUDOFRM (57)
CREATE OR REPLACE FUNCTION SP_GIROSDCONADEUDO_LIST() RETURNS TABLE(giro VARCHAR(255), licencias_con_adeudo INTEGER, monto_total_adeudo NUMERIC(15,2)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT l.giro, COUNT(*)::INTEGER, SUM(a.monto_adeudo) FROM public.licencias_comerciales l JOIN public.adeudos_licencias a ON l.numero_licencia = a.numero_licencia WHERE a.estado_adeudo = 'PENDIENTE' GROUP BY l.giro ORDER BY SUM(a.monto_adeudo) DESC; END; $$;

-- GIROSVIGENTESCTEXGIROFRM (58)
CREATE OR REPLACE FUNCTION SP_GIROSVIGENTESCTEX_LIST() RETURNS TABLE(giro VARCHAR(255), cliente VARCHAR(255), cantidad_licencias INTEGER) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT l.giro, l.propietario, COUNT(*)::INTEGER FROM public.licencias_comerciales l WHERE l.estado = 'VIGENTE' GROUP BY l.giro, l.propietario HAVING COUNT(*) > 1 ORDER BY COUNT(*) DESC; END; $$;