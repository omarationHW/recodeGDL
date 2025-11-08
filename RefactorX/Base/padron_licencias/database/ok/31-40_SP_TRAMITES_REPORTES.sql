-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULOS 31-40: TRÁMITES Y REPORTES
-- ============================================

-- MODTRAMITEFRM (31)
CREATE OR REPLACE FUNCTION SP_MODTRAMITE_LIST() RETURNS TABLE(numero_tramite VARCHAR(100), solicitante VARCHAR(255), estado VARCHAR(30), fecha_modificacion DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT m.numero_tramite, m.solicitante, m.estado, m.fecha_modificacion FROM public.modificaciones_tramites m ORDER BY m.fecha_modificacion DESC; END; $$;
CREATE OR REPLACE FUNCTION SP_MODTRAMITE_UPDATE(p_numero_tramite VARCHAR(100), p_nuevos_datos TEXT) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN UPDATE public.tramites SET datos_actualizados = p_nuevos_datos WHERE numero_tramite = p_numero_tramite; RETURN QUERY SELECT TRUE, 'Trámite modificado correctamente'; END; $$;

-- CANCELATRAMITEFRM (32)
CREATE OR REPLACE FUNCTION SP_CANCELATRAMITE_CANCEL(p_numero_tramite VARCHAR(100), p_motivo_cancelacion TEXT) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN UPDATE public.tramites SET estado = 'CANCELADO', motivo_cancelacion = p_motivo_cancelacion WHERE numero_tramite = p_numero_tramite; RETURN QUERY SELECT TRUE, 'Trámite cancelado'; END; $$;

-- BLOQUEARTRAMITEFRM (33)
CREATE OR REPLACE FUNCTION SP_BLOQUEARTRAMITE_BLOCK(p_numero_tramite VARCHAR(100), p_motivo_bloqueo TEXT) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN UPDATE public.tramites SET estado = 'BLOQUEADO', motivo_bloqueo = p_motivo_bloqueo WHERE numero_tramite = p_numero_tramite; RETURN QUERY SELECT TRUE, 'Trámite bloqueado'; END; $$;

-- REACTIVATRAMITE (34)
CREATE OR REPLACE FUNCTION SP_REACTIVATRAMITE_REACTIVATE(p_numero_tramite VARCHAR(100)) RETURNS TABLE(success BOOLEAN, message TEXT) LANGUAGE plpgsql AS $$ BEGIN UPDATE public.tramites SET estado = 'EN_PROCESO', fecha_reactivacion = CURRENT_DATE WHERE numero_tramite = p_numero_tramite; RETURN QUERY SELECT TRUE, 'Trámite reactivado'; END; $$;

-- TRAMITEBAJALIC (35)
CREATE OR REPLACE FUNCTION SP_TRAMITEBAJALIC_LIST() RETURNS TABLE(numero_tramite VARCHAR(100), numero_licencia VARCHAR(100), fecha_solicitud DATE, estado VARCHAR(30)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT t.numero_tramite, t.numero_licencia, t.fecha_solicitud, t.estado FROM public.tramites_baja_licencia t ORDER BY t.fecha_solicitud DESC; END; $$;

-- TRAMITEBAJAANUN (36)
CREATE OR REPLACE FUNCTION SP_TRAMITEBAJAANUN_LIST() RETURNS TABLE(numero_tramite VARCHAR(100), numero_anuncio VARCHAR(100), fecha_solicitud DATE, estado VARCHAR(30)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT t.numero_tramite, t.numero_anuncio, t.fecha_solicitud, t.estado FROM public.tramites_baja_anuncio t ORDER BY t.fecha_solicitud DESC; END; $$;

-- REPESTADISTICOSLICFRM (37)
CREATE OR REPLACE FUNCTION SP_REPESTADISTICOSLIC_GENERATE() RETURNS TABLE(periodo VARCHAR(20), licencias_expedidas INTEGER, licencias_renovadas INTEGER, ingresos_total NUMERIC(15,2)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT TO_CHAR(l.fecha_expedicion, 'YYYY-MM') as periodo, COUNT(CASE WHEN l.tipo_solicitud = 'NUEVA' THEN 1 END)::INTEGER as expedidas, COUNT(CASE WHEN l.tipo_solicitud = 'RENOVACION' THEN 1 END)::INTEGER as renovadas, SUM(l.monto_pagado) as ingresos FROM public.licencias_comerciales l WHERE l.fecha_expedicion >= CURRENT_DATE - INTERVAL '12 months' GROUP BY TO_CHAR(l.fecha_expedicion, 'YYYY-MM') ORDER BY periodo DESC; END; $$;

-- REPORTEANUNEXCELFRM (38)
CREATE OR REPLACE FUNCTION SP_REPORTEANUNEXCEL_DATA() RETURNS TABLE(numero_anuncio VARCHAR(100), propietario VARCHAR(255), direccion TEXT, tipo_anuncio VARCHAR(50), estado VARCHAR(30), fecha_autorizacion DATE) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT a.numero_anuncio, a.propietario, a.direccion_anuncio, a.tipo_anuncio, a.estado, a.fecha_autorizacion FROM public.anuncios_publicitarios a ORDER BY a.fecha_autorizacion DESC; END; $$;

-- REPSUSPENDIDASFRM (39)
CREATE OR REPLACE FUNCTION SP_REPSUSPENDIDAS_LIST() RETURNS TABLE(numero_licencia VARCHAR(100), propietario VARCHAR(255), fecha_suspension DATE, motivo_suspension TEXT) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT l.numero_licencia, l.propietario, l.fecha_suspension, l.motivo_suspension FROM public.licencias_comerciales l WHERE l.estado = 'SUSPENDIDA' ORDER BY l.fecha_suspension DESC; END; $$;

-- REPESTADO (40)
CREATE OR REPLACE FUNCTION SP_REPESTADO_SUMMARY() RETURNS TABLE(estado VARCHAR(30), cantidad_licencias INTEGER, porcentaje NUMERIC(5,2)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT l.estado, COUNT(*)::INTEGER, (COUNT(*) * 100.0 / SUM(COUNT(*)) OVER())::NUMERIC(5,2) FROM public.licencias_comerciales l GROUP BY l.estado ORDER BY COUNT(*) DESC; END; $$;