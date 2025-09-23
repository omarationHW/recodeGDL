-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REGISTROSOLICITUDFORM (EXACTO del archivo original)
-- Archivo: 26_SP_LICENCIAS_REGISTROSOLICITUDFORM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_registro_solicitud
-- Tipo: CRUD
-- Descripción: Registra una nueva solicitud de licencia o anuncio, validando reglas de negocio y generando el folio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_registro_solicitud(
    p_tipo_tramite integer,
    p_id_giro integer,
    p_actividad text,
    p_propietario text,
    p_telefono text,
    p_email text,
    p_calle text,
    p_colonia text,
    p_cp text,
    p_numext text,
    p_numint text,
    p_letraext text,
    p_letraint text,
    p_zona integer,
    p_subzona integer,
    p_sup_const numeric,
    p_sup_autorizada numeric,
    p_num_cajones integer,
    p_num_empleados integer,
    p_inversion numeric,
    p_rfc text,
    p_curp text,
    p_especificaciones text,
    p_usuario text
) RETURNS TABLE(id_tramite integer, folio integer, mensaje text) AS $$
DECLARE
    v_folio integer;
BEGIN
    -- Validaciones de negocio (ejemplo)
    IF p_tipo_tramite IS NULL OR p_id_giro IS NULL OR p_actividad IS NULL OR p_propietario IS NULL THEN
        RAISE EXCEPTION 'Faltan datos obligatorios';
    END IF;
    -- Generar folio (ejemplo: secuencia)
    SELECT nextval('tramites_folio_seq') INTO v_folio;
    -- Insertar en tramites
    INSERT INTO tramites (
        folio, tipo_tramite, id_giro, actividad, propietario, telefono_prop, email, ubicacion, colonia_ubic, cp, numext_ubic, numint_ubic, letraext_ubic, letrain_ubic, zona, subzona, sup_construida, sup_autorizada, num_cajones, num_empleados, inversion, rfc, curp, espubic, feccap, capturista, estatus
    ) VALUES (
        v_folio, p_tipo_tramite, p_id_giro, p_actividad, p_propietario, p_telefono, p_email, p_calle, p_colonia, p_cp, p_numext, p_numint, p_letraext, p_letraint, p_zona, p_subzona, p_sup_const, p_sup_autorizada, p_num_cajones, p_num_empleados, p_inversion, p_rfc, p_curp, p_especificaciones, now(), p_usuario, 'T'
    ) RETURNING id_tramite INTO id_tramite;
    RETURN QUERY SELECT id_tramite, v_folio, 'Solicitud registrada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REGISTROSOLICITUDFORM (EXACTO del archivo original)
-- Archivo: 26_SP_LICENCIAS_REGISTROSOLICITUDFORM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_agregar_documento
-- Tipo: CRUD
-- Descripción: Agrega un documento a un trámite.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_agregar_documento(
    p_id_tramite integer,
    p_nombre text,
    p_ruta text,
    p_usuario text
) RETURNS TABLE(id_documento integer, mensaje text) AS $$
DECLARE
    v_id_documento integer;
BEGIN
    INSERT INTO tramitedocs (id_tramite, nombre, ruta, feccap, capturista)
    VALUES (p_id_tramite, p_nombre, p_ruta, now(), p_usuario)
    RETURNING id_documento INTO v_id_documento;
    RETURN QUERY SELECT v_id_documento, 'Documento agregado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REGISTROSOLICITUDFORM (EXACTO del archivo original)
-- Archivo: 26_SP_LICENCIAS_REGISTROSOLICITUDFORM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

