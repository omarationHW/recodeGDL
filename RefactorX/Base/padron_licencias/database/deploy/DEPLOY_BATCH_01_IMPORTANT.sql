-- ============================================================
-- DEPLOY BATCH #1: 10 SPs IMPORTANTES
-- Base de datos: padron_licencias
-- Fecha: 2025-11-10
-- ============================================================
--
-- Este script crea el BATCH #1 de 10 Stored Procedures IMPORTANTES
-- Progreso: De 68/312 (20.7%) → 78/312 (25.0%)
--
-- ============================================================

-- ============================================================
-- SP: sp_get_giro_by_id
-- ============================================================
-- Descripción: Obtiene información de un giro por ID
-- Tabla: comun.c_giros
-- Tipo: READ
-- ============================================================

CREATE OR REPLACE FUNCTION sp_get_giro_by_id(
    p_id_giro INTEGER
)
RETURNS TABLE (
    id_giro INTEGER,
    id_mensaje INTEGER,
    cod_giro INTEGER,
    cod_anun CHARACTER VARYING(5),
    descripcion CHARACTER VARYING(96),
    caracteristicas CHARACTER VARYING(130),
    clasificacion CHARACTER VARYING(1),
    tipo CHARACTER VARYING(1),
    ctaaplic INTEGER,
    reglamentada CHARACTER VARYING(1),
    ctaaplic_rez INTEGER,
    vigente CHARACTER VARYING(1),
    ctaaplicref INTEGER,
    ctaaplicref_rez INTEGER
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_giro,
        t.id_mensaje,
        t.cod_giro,
        t.cod_anun,
        t.descripcion,
        t.caracteristicas,
        t.clasificacion,
        t.tipo,
        t.ctaaplic,
        t.reglamentada,
        t.ctaaplic_rez,
        t.vigente,
        t.ctaaplicref,
        t.ctaaplicref_rez
    FROM comun.c_giros t
    WHERE t.id_giro = p_id_giro;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_get_giro_by_id(INTEGER) IS
'Obtiene información de un giro por ID. Tabla: comun.c_giros';


-- ============================================================
-- SP: sp_cancel_tramite
-- ============================================================
-- Descripción: Cancela un trámite (marca estatus como cancelado)
-- Tabla: public.h_tramites
-- Tipo: UPDATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_cancel_tramite(
    p_id_tramite INTEGER,
    p_folio INTEGER,
    p_tipo_tramite CHARACTER VARYING(2),
    p_id_giro INTEGER,
    p_x NUMERIC,
    p_y NUMERIC,
    p_zona SMALLINT,
    p_subzona SMALLINT,
    p_actividad CHARACTER VARYING(130),
    p_cvecuenta INTEGER,
    p_recaud SMALLINT,
    p_licencia_ref INTEGER,
    p_tramita_apoderado CHARACTER VARYING(100),
    p_propietario CHARACTER VARYING(80),
    p_primer_ap CHARACTER VARYING(80),
    p_segundo_ap CHARACTER VARYING(80),
    p_rfc CHARACTER VARYING(13),
    p_curp CHARACTER VARYING(18),
    p_domicilio CHARACTER VARYING(50),
    p_numext_prop INTEGER,
    p_numint_prop CHARACTER VARYING(5),
    p_colonia_prop CHARACTER VARYING(25),
    p_telefono_prop CHARACTER VARYING(30),
    p_email CHARACTER VARYING(50),
    p_cvecalle INTEGER,
    p_ubicacion CHARACTER VARYING(50),
    p_numext_ubic INTEGER,
    p_letraext_ubic CHARACTER VARYING(3),
    p_letraint_ubic CHARACTER VARYING(3),
    p_colonia_ubic CHARACTER VARYING(25),
    p_espubic CHARACTER VARYING(60),
    p_documentos TEXT,
    p_sup_construida NUMERIC,
    p_sup_autorizada NUMERIC,
    p_num_cajones SMALLINT,
    p_num_empleados SMALLINT,
    p_aforo SMALLINT,
    p_inversion NUMERIC,
    p_costo NUMERIC,
    p_fecha_consejo DATE,
    p_id_fabricante INTEGER,
    p_texto_anuncio CHARACTER VARYING(50),
    p_medidas1 NUMERIC,
    p_medidas2 NUMERIC,
    p_area_anuncio NUMERIC,
    p_num_caras SMALLINT,
    p_calificacion NUMERIC,
    p_usr_califica CHARACTER VARYING(10),
    p_estatus CHARACTER VARYING(1),
    p_id_licencia INTEGER,
    p_id_anuncio INTEGER,
    p_feccap DATE,
    p_capturista CHARACTER VARYING(10),
    p_numint_ubic CHARACTER VARYING(5),
    p_bloqueado SMALLINT,
    p_dictamen SMALLINT,
    p_observaciones TEXT,
    p_rhorario CHARACTER VARYING(50),
    p_cp INTEGER,
    p_fecmov TIMESTAMP WITHOUT TIME ZONE,
    p_usuariomov CHARACTER VARYING(10)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE public.h_tramites
    SET
        folio = p_folio,
        tipo_tramite = p_tipo_tramite,
        id_giro = p_id_giro,
        x = p_x,
        y = p_y,
        zona = p_zona,
        subzona = p_subzona,
        actividad = p_actividad,
        cvecuenta = p_cvecuenta,
        recaud = p_recaud,
        licencia_ref = p_licencia_ref,
        tramita_apoderado = p_tramita_apoderado,
        propietario = p_propietario,
        primer_ap = p_primer_ap,
        segundo_ap = p_segundo_ap,
        rfc = p_rfc,
        curp = p_curp,
        domicilio = p_domicilio,
        numext_prop = p_numext_prop,
        numint_prop = p_numint_prop,
        colonia_prop = p_colonia_prop,
        telefono_prop = p_telefono_prop,
        email = p_email,
        cvecalle = p_cvecalle,
        ubicacion = p_ubicacion,
        numext_ubic = p_numext_ubic,
        letraext_ubic = p_letraext_ubic,
        letraint_ubic = p_letraint_ubic,
        colonia_ubic = p_colonia_ubic,
        espubic = p_espubic,
        documentos = p_documentos,
        sup_construida = p_sup_construida,
        sup_autorizada = p_sup_autorizada,
        num_cajones = p_num_cajones,
        num_empleados = p_num_empleados,
        aforo = p_aforo,
        inversion = p_inversion,
        costo = p_costo,
        fecha_consejo = p_fecha_consejo,
        id_fabricante = p_id_fabricante,
        texto_anuncio = p_texto_anuncio,
        medidas1 = p_medidas1,
        medidas2 = p_medidas2,
        area_anuncio = p_area_anuncio,
        num_caras = p_num_caras,
        calificacion = p_calificacion,
        usr_califica = p_usr_califica,
        estatus = p_estatus,
        id_licencia = p_id_licencia,
        id_anuncio = p_id_anuncio,
        feccap = p_feccap,
        capturista = p_capturista,
        numint_ubic = p_numint_ubic,
        bloqueado = p_bloqueado,
        dictamen = p_dictamen,
        observaciones = p_observaciones,
        rhorario = p_rhorario,
        cp = p_cp,
        fecmov = p_fecmov,
        usuariomov = p_usuariomov
    WHERE id_tramite = p_id_tramite;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Registro actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Registro no encontrado'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_cancel_tramite IS
'Cancela un trámite (marca estatus como cancelado). Tabla: public.h_tramites';


-- ============================================================
-- SP: carga_delete_predio
-- ============================================================
-- Descripción: Elimina información de predio de la carga temporal
-- Tabla: comun.catastro
-- Tipo: DELETE
-- ============================================================

CREATE OR REPLACE FUNCTION carga_delete_predio(
    p_cvecuenta INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE comun.catastro
    SET vigente = '0'
    WHERE cvecuenta = p_cvecuenta;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Registro eliminado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Registro no encontrado'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION carga_delete_predio(INTEGER) IS
'Elimina información de predio de la carga temporal. Tabla: comun.catastro';


-- ============================================================
-- SP: sp_save_cargadatos
-- ============================================================
-- Descripción: Guarda datos de carga temporal de predios
-- Tabla: comun.catastro
-- Tipo: CREATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_save_cargadatos(
    p_cvecuenta INTEGER,
    p_cvemov INTEGER,
    p_cvevalor INTEGER,
    p_cveubic INTEGER,
    p_cvecartografia INTEGER,
    p_cveregprop INTEGER,
    p_cveavaluo INTEGER,
    p_folio INTEGER,
    p_asiento INTEGER,
    p_axoefec SMALLINT,
    p_bimefec SMALLINT,
    p_axocomp SMALLINT,
    p_nocomp INTEGER,
    p_axoultcomp SMALLINT,
    p_ultcomp INTEGER,
    p_observacion TEXT,
    p_vigente CHARACTER VARYING(1),
    p_feccap DATE,
    p_capturista CHARACTER VARYING(10),
    p_areatitulo NUMERIC,
    p_computer CHARACTER VARYING(45),
    p_fecaps TIMESTAMP WITHOUT TIME ZONE
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    cvecuenta INTEGER
)
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    INSERT INTO comun.catastro (cvecuenta, cvemov, cvevalor, cveubic, cvecartografia, cveregprop, cveavaluo, folio, asiento, axoefec, bimefec, axocomp, nocomp, axoultcomp, ultcomp, observacion, vigente, feccap, capturista, areatitulo, computer, fecaps)
    VALUES (p_cvecuenta, p_cvemov, p_cvevalor, p_cveubic, p_cvecartografia, p_cveregprop, p_cveavaluo, p_folio, p_asiento, p_axoefec, p_bimefec, p_axocomp, p_nocomp, p_axoultcomp, p_ultcomp, p_observacion, p_vigente, p_feccap, p_capturista, p_areatitulo, p_computer, p_fecaps)
    RETURNING cvecuenta INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro creado exitosamente'::TEXT, v_new_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_save_cargadatos IS
'Guarda datos de carga temporal de predios. Tabla: comun.catastro';


-- ============================================================
-- SP: carga_imagen_sp_delete_document_image
-- ============================================================
-- Descripción: Elimina imagen de documento digital
-- Tabla: public.digital_docs
-- Tipo: DELETE
-- ============================================================

CREATE OR REPLACE FUNCTION carga_imagen_sp_delete_document_image(
    p_id_imagen INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    DELETE FROM public.digital_docs
    WHERE id_imagen = p_id_imagen;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Registro eliminado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Registro no encontrado'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION carga_imagen_sp_delete_document_image(INTEGER) IS
'Elimina imagen de documento digital. Tabla: public.digital_docs';


-- ============================================================
-- SP: sp_catalogo_actividades_create
-- ============================================================
-- Descripción: Crea nueva actividad en catálogo
-- Tabla: public.c_actividades_lic
-- Tipo: CREATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_catalogo_actividades_create(
    p_id_giro INTEGER,
    p_descripcion CHARACTER VARYING(250),
    p_observaciones CHARACTER VARYING(100),
    p_vigente CHARACTER VARYING(1),
    p_fecha_alta TIMESTAMP WITHOUT TIME ZONE,
    p_usuario_alta CHARACTER VARYING(12),
    p_fecha_baja TIMESTAMP WITHOUT TIME ZONE,
    p_usuario_baja CHARACTER VARYING(12),
    p_motivo_baja CHARACTER VARYING(100)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_actividad INTEGER
)
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    INSERT INTO public.c_actividades_lic (id_giro, descripcion, observaciones, vigente, fecha_alta, usuario_alta, fecha_baja, usuario_baja, motivo_baja)
    VALUES (p_id_giro, p_descripcion, p_observaciones, p_vigente, p_fecha_alta, p_usuario_alta, p_fecha_baja, p_usuario_baja, p_motivo_baja)
    RETURNING id_actividad INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro creado exitosamente'::TEXT, v_new_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_catalogo_actividades_create IS
'Crea nueva actividad en catálogo. Tabla: public.c_actividades_lic';


-- ============================================================
-- SP: sp_catalogo_actividades_update
-- ============================================================
-- Descripción: Actualiza actividad existente
-- Tabla: public.c_actividades_lic
-- Tipo: UPDATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_catalogo_actividades_update(
    p_id_actividad INTEGER,
    p_id_giro INTEGER,
    p_descripcion CHARACTER VARYING(250),
    p_observaciones CHARACTER VARYING(100),
    p_vigente CHARACTER VARYING(1),
    p_fecha_alta TIMESTAMP WITHOUT TIME ZONE,
    p_usuario_alta CHARACTER VARYING(12),
    p_fecha_baja TIMESTAMP WITHOUT TIME ZONE,
    p_usuario_baja CHARACTER VARYING(12),
    p_motivo_baja CHARACTER VARYING(100)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE public.c_actividades_lic
    SET
        id_giro = p_id_giro,
        descripcion = p_descripcion,
        observaciones = p_observaciones,
        vigente = p_vigente,
        fecha_alta = p_fecha_alta,
        usuario_alta = p_usuario_alta,
        fecha_baja = p_fecha_baja,
        usuario_baja = p_usuario_baja,
        motivo_baja = p_motivo_baja
    WHERE id_actividad = p_id_actividad;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Registro actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Registro no encontrado'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_catalogo_actividades_update IS
'Actualiza actividad existente. Tabla: public.c_actividades_lic';


-- ============================================================
-- SP: sp_catalogo_actividades_delete
-- ============================================================
-- Descripción: Elimina/inactiva actividad del catálogo
-- Tabla: public.c_actividades_lic
-- Tipo: DELETE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_catalogo_actividades_delete(
    p_id_actividad INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE public.c_actividades_lic
    SET vigente = '0'
    WHERE id_actividad = p_id_actividad;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Registro eliminado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Registro no encontrado'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_catalogo_actividades_delete(INTEGER) IS
'Elimina/inactiva actividad del catálogo. Tabla: public.c_actividades_lic';


-- ============================================================
-- SP: sp_catalogogiros_create
-- ============================================================
-- Descripción: Crea nuevo giro en catálogo
-- Tabla: comun.c_giros
-- Tipo: CREATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_catalogogiros_create(
    p_id_giro INTEGER,
    p_id_mensaje INTEGER,
    p_cod_giro INTEGER,
    p_cod_anun CHARACTER VARYING(5),
    p_descripcion CHARACTER VARYING(96),
    p_caracteristicas CHARACTER VARYING(130),
    p_clasificacion CHARACTER VARYING(1),
    p_tipo CHARACTER VARYING(1),
    p_ctaaplic INTEGER,
    p_reglamentada CHARACTER VARYING(1),
    p_ctaaplic_rez INTEGER,
    p_vigente CHARACTER VARYING(1),
    p_ctaaplicref INTEGER,
    p_ctaaplicref_rez INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id_giro INTEGER
)
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    INSERT INTO comun.c_giros (id_giro, id_mensaje, cod_giro, cod_anun, descripcion, caracteristicas, clasificacion, tipo, ctaaplic, reglamentada, ctaaplic_rez, vigente, ctaaplicref, ctaaplicref_rez)
    VALUES (p_id_giro, p_id_mensaje, p_cod_giro, p_cod_anun, p_descripcion, p_caracteristicas, p_clasificacion, p_tipo, p_ctaaplic, p_reglamentada, p_ctaaplic_rez, p_vigente, p_ctaaplicref, p_ctaaplicref_rez)
    RETURNING id_giro INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro creado exitosamente'::TEXT, v_new_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_catalogogiros_create IS
'Crea nuevo giro en catálogo. Tabla: comun.c_giros';


-- ============================================================
-- SP: sp_catalogogiros_update
-- ============================================================
-- Descripción: Actualiza giro existente
-- Tabla: comun.c_giros
-- Tipo: UPDATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_catalogogiros_update(
    p_id_giro INTEGER,
    p_id_mensaje INTEGER,
    p_cod_giro INTEGER,
    p_cod_anun CHARACTER VARYING(5),
    p_descripcion CHARACTER VARYING(96),
    p_caracteristicas CHARACTER VARYING(130),
    p_clasificacion CHARACTER VARYING(1),
    p_tipo CHARACTER VARYING(1),
    p_ctaaplic INTEGER,
    p_reglamentada CHARACTER VARYING(1),
    p_ctaaplic_rez INTEGER,
    p_vigente CHARACTER VARYING(1),
    p_ctaaplicref INTEGER,
    p_ctaaplicref_rez INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE comun.c_giros
    SET
        id_mensaje = p_id_mensaje,
        cod_giro = p_cod_giro,
        cod_anun = p_cod_anun,
        descripcion = p_descripcion,
        caracteristicas = p_caracteristicas,
        clasificacion = p_clasificacion,
        tipo = p_tipo,
        ctaaplic = p_ctaaplic,
        reglamentada = p_reglamentada,
        ctaaplic_rez = p_ctaaplic_rez,
        vigente = p_vigente,
        ctaaplicref = p_ctaaplicref,
        ctaaplicref_rez = p_ctaaplicref_rez
    WHERE id_giro = p_id_giro;

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Registro actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Registro no encontrado'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_catalogogiros_update IS
'Actualiza giro existente. Tabla: comun.c_giros';


-- ============================================================
-- VERIFICACIÓN DE CREACIÓN
-- ============================================================

SELECT
    routine_schema,
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_name IN (
    'sp_get_giro_by_id',
    'sp_cancel_tramite',
    'carga_delete_predio',
    'sp_save_cargadatos',
    'carga_imagen_sp_delete_document_image',
    'sp_catalogo_actividades_create',
    'sp_catalogo_actividades_update',
    'sp_catalogo_actividades_delete',
    'sp_catalogogiros_create',
    'sp_catalogogiros_update'
)
AND routine_schema = 'public'
ORDER BY routine_name;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
