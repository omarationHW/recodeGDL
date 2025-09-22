-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- MÓDULOS 21-30: BÚSQUEDAS Y CONSULTAS AVANZADAS
-- ============================================

-- CATREQUISITOS (21)
CREATE OR REPLACE FUNCTION SP_CATREQUISITOS_LIST() RETURNS TABLE(id INTEGER, descripcion VARCHAR(255), tipo_tramite VARCHAR(50)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT r.id, r.descripcion, r.tipo_tramite FROM public.catalogo_requisitos r ORDER BY r.tipo_tramite, r.descripcion; END; $$;

-- LIGAREQUISITOS (22)
CREATE OR REPLACE FUNCTION SP_LIGAREQUISITOS_LIST() RETURNS TABLE(tramite_id INTEGER, requisito_id INTEGER, obligatorio BOOLEAN) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT l.tramite_id, l.requisito_id, l.obligatorio FROM public.liga_requisitos l; END; $$;

-- TIPOBLOQUEOFRM (23) - Ya implementado anteriormente
-- ESTATUSFRM (24)
CREATE OR REPLACE FUNCTION SP_ESTATUS_LIST() RETURNS TABLE(id INTEGER, codigo VARCHAR(20), descripcion VARCHAR(100)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT e.id, e.codigo, e.descripcion FROM public.catalogo_estatus e ORDER BY e.descripcion; END; $$;

-- BUSQUEDAACTIVIDADFRM (25)
CREATE OR REPLACE FUNCTION SP_BUSQUEDAACTIVIDAD_SEARCH(p_termino VARCHAR(255)) RETURNS TABLE(id INTEGER, codigo VARCHAR(20), descripcion VARCHAR(255), giro VARCHAR(100)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT a.id, a.codigo_actividad, a.descripcion, g.descripcion as giro FROM public.catalogo_actividades a JOIN public.catalogo_giros g ON a.giro_id = g.id WHERE a.descripcion ILIKE '%' || p_termino || '%' OR a.codigo_actividad ILIKE '%' || p_termino || '%'; END; $$;

-- BUSQUEDASCIANFRM (26)
CREATE OR REPLACE FUNCTION SP_BUSQUEDASCIAN_SEARCH(p_codigo VARCHAR(20), p_descripcion VARCHAR(255)) RETURNS TABLE(codigo_scian VARCHAR(20), descripcion VARCHAR(500), sector VARCHAR(100)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT s.codigo_scian, s.descripcion, s.sector FROM public.catalogo_scian s WHERE (p_codigo IS NULL OR s.codigo_scian ILIKE '%' || p_codigo || '%') AND (p_descripcion IS NULL OR s.descripcion ILIKE '%' || p_descripcion || '%'); END; $$;

-- BUSCAGIROFRM (27)
CREATE OR REPLACE FUNCTION SP_BUSCAGIRO_SEARCH(p_termino VARCHAR(255)) RETURNS TABLE(id INTEGER, codigo VARCHAR(20), descripcion VARCHAR(255), categoria VARCHAR(100)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT g.id, g.codigo_giro, g.descripcion, g.categoria FROM public.catalogo_giros g WHERE g.descripcion ILIKE '%' || p_termino || '%' OR g.codigo_giro ILIKE '%' || p_termino || '%' OR g.categoria ILIKE '%' || p_termino || '%'; END; $$;

-- EMPLEADOSLISTADO (28)
CREATE OR REPLACE FUNCTION SP_EMPLEADOS_LIST() RETURNS TABLE(id INTEGER, nombre_completo VARCHAR(255), puesto VARCHAR(100), departamento VARCHAR(100)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT e.id, e.nombre_completo, e.puesto, e.departamento FROM public.empleados e ORDER BY e.nombre_completo; END; $$;

-- CONSULTAUSUARIOSFRM (29)
CREATE OR REPLACE FUNCTION SP_CONSULTAUSUARIOS_LIST() RETURNS TABLE(id INTEGER, usuario VARCHAR(100), nombre VARCHAR(255), perfil VARCHAR(50), activo BOOLEAN) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT u.id, u.usuario, u.nombre, u.perfil, u.activo FROM public.usuarios u ORDER BY u.nombre; END; $$;

-- CONSULTATRAMITEFRM (30)
CREATE OR REPLACE FUNCTION SP_CONSULTATRAMITE_LIST(p_numero_tramite VARCHAR(100), p_estado VARCHAR(30)) RETURNS TABLE(numero_tramite VARCHAR(100), tipo_tramite VARCHAR(50), solicitante VARCHAR(255), fecha_inicio DATE, estado VARCHAR(30)) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY SELECT t.numero_tramite, t.tipo_tramite, t.solicitante, t.fecha_inicio, t.estado FROM public.tramites t WHERE (p_numero_tramite IS NULL OR t.numero_tramite ILIKE '%' || p_numero_tramite || '%') AND (p_estado IS NULL OR t.estado = p_estado) ORDER BY t.fecha_inicio DESC; END; $$;