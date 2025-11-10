-- ============================================================
-- DEPLOY BATCH #2: 10 SPs IMPORTANTES
-- Base de datos: padron_licencias
-- Fecha: 2025-11-10
-- ============================================================
--
-- Este script crea el BATCH #2 de 10 Stored Procedures IMPORTANTES
-- Progreso: De 78/312 (25.0%) → 88/312 (28.2%)
--
-- ============================================================

-- ============================================================
-- SP: sp_solicnooficial_create
-- ============================================================
-- Descripción: Crea nueva solicitud no oficial
-- Tabla: public.solicnooficial
-- Tipo: CREATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_solicnooficial_create(
    p_axo INTEGER,
    p_folio INTEGER,
    p_propietario CHARACTER VARYING(50),
    p_actividad CHARACTER VARYING(80),
    p_ubicacion CHARACTER VARYING(75),
    p_zona SMALLINT,
    p_subzona SMALLINT,
    p_vigente CHARACTER VARYING(1),
    p_feccap DATE,
    p_capturista CHARACTER VARYING(10)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    axo INTEGER
)
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    INSERT INTO public.solicnooficial (axo, folio, propietario, actividad, ubicacion, zona, subzona, vigente, feccap, capturista)
    VALUES (p_axo, p_folio, p_propietario, p_actividad, p_ubicacion, p_zona, p_subzona, p_vigente, p_feccap, p_capturista)
    RETURNING axo INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro creado exitosamente'::TEXT, v_new_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_solicnooficial_create IS
'Crea nueva solicitud no oficial. Tabla: public.solicnooficial';


-- ============================================================
-- SP: sp_solicnooficial_update
-- ============================================================
-- Descripción: Actualiza solicitud no oficial
-- Tabla: public.solicnooficial
-- Tipo: UPDATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_solicnooficial_update(
    p_axo INTEGER,
    p_folio INTEGER,
    p_propietario CHARACTER VARYING(50),
    p_actividad CHARACTER VARYING(80),
    p_ubicacion CHARACTER VARYING(75),
    p_zona SMALLINT,
    p_subzona SMALLINT,
    p_vigente CHARACTER VARYING(1),
    p_feccap DATE,
    p_capturista CHARACTER VARYING(10)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE public.solicnooficial
    SET
        folio = p_folio,
        propietario = p_propietario,
        actividad = p_actividad,
        ubicacion = p_ubicacion,
        zona = p_zona,
        subzona = p_subzona,
        vigente = p_vigente,
        feccap = p_feccap,
        capturista = p_capturista
    WHERE axo = p_axo;

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

COMMENT ON FUNCTION sp_solicnooficial_update IS
'Actualiza solicitud no oficial. Tabla: public.solicnooficial';


-- ============================================================
-- SP: sp_solicnooficial_cancel
-- ============================================================
-- Descripción: Cancela solicitud no oficial
-- Tabla: public.solicnooficial
-- Tipo: DELETE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_solicnooficial_cancel(
    p_axo INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE public.solicnooficial
    SET vigente = '0'
    WHERE axo = p_axo;

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

COMMENT ON FUNCTION sp_solicnooficial_cancel(INTEGER) IS
'Cancela solicitud no oficial. Tabla: public.solicnooficial';


-- ============================================================
-- SP: sp_dependencias_create
-- ============================================================
-- Descripción: Crea nueva dependencia
-- Tabla: comun.c_dependencias
-- Tipo: CREATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_dependencias_create(
    p_descripcion CHARACTER VARYING(50),
    p_tipo CHARACTER VARYING(1),
    p_cvectaapl INTEGER,
    p_abrevia CHARACTER VARYING(20),
    p_licencias SMALLINT,
    p_vigencia CHARACTER VARYING(1),
    p_feccap DATE,
    p_capturista CHARACTER VARYING(10),
    p_cta_vencido INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id INTEGER
)
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    INSERT INTO comun.c_dependencias (descripcion, tipo, cvectaapl, abrevia, licencias, vigencia, feccap, capturista, cta_vencido)
    VALUES (p_descripcion, p_tipo, p_cvectaapl, p_abrevia, p_licencias, p_vigencia, p_feccap, p_capturista, p_cta_vencido)
    RETURNING id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro creado exitosamente'::TEXT, v_new_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_dependencias_create IS
'Crea nueva dependencia. Tabla: comun.c_dependencias';


-- ============================================================
-- SP: sp_dependencias_update
-- ============================================================
-- Descripción: Actualiza dependencia
-- Tabla: comun.c_dependencias
-- Tipo: UPDATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_dependencias_update(
    p_id_dependencia INTEGER,
    p_descripcion CHARACTER VARYING(50),
    p_tipo CHARACTER VARYING(1),
    p_cvectaapl INTEGER,
    p_abrevia CHARACTER VARYING(20),
    p_licencias SMALLINT,
    p_vigencia CHARACTER VARYING(1),
    p_feccap DATE,
    p_capturista CHARACTER VARYING(10),
    p_cta_vencido INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE comun.c_dependencias
    SET
        id_dependencia = p_id_dependencia,
        descripcion = p_descripcion,
        tipo = p_tipo,
        cvectaapl = p_cvectaapl,
        abrevia = p_abrevia,
        licencias = p_licencias,
        vigencia = p_vigencia,
        feccap = p_feccap,
        capturista = p_capturista,
        cta_vencido = p_cta_vencido
    WHERE id = p_id;

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

COMMENT ON FUNCTION sp_dependencias_update IS
'Actualiza dependencia. Tabla: comun.c_dependencias';


-- ============================================================
-- SP: sp_dependencias_delete
-- ============================================================
-- Descripción: Elimina dependencia
-- Tabla: comun.c_dependencias
-- Tipo: DELETE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_dependencias_delete(
    p_id INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    DELETE FROM comun.c_dependencias
    WHERE id = p_id;

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

COMMENT ON FUNCTION sp_dependencias_delete(INTEGER) IS
'Elimina dependencia. Tabla: comun.c_dependencias';


-- ============================================================
-- SP: sp_dictamenes_create
-- ============================================================
-- Descripción: Crea nuevo dictamen
-- Tabla: comun.dictamenes
-- Tipo: CREATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_dictamenes_create(
    p_id_giro INTEGER,
    p_propietario CHARACTER VARYING(100),
    p_domicilio CHARACTER VARYING(100),
    p_no_exterior CHARACTER VARYING(5),
    p_no_interior CHARACTER VARYING(5),
    p_supconst DOUBLE PRECISION,
    p_area_util DOUBLE PRECISION,
    p_num_cajones INTEGER,
    p_actividad CHARACTER VARYING(100),
    p_uso_suelo CHARACTER VARYING(200),
    p_desc_uso CHARACTER VARYING(120),
    p_zona INTEGER,
    p_subzona INTEGER,
    p_dictamen CHARACTER VARYING(1),
    p_capturista CHARACTER VARYING(10),
    p_fecha DATE
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    id INTEGER
)
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    INSERT INTO comun.dictamenes (id_giro, propietario, domicilio, no_exterior, no_interior, supconst, area_util, num_cajones, actividad, uso_suelo, desc_uso, zona, subzona, dictamen, capturista, fecha)
    VALUES (p_id_giro, p_propietario, p_domicilio, p_no_exterior, p_no_interior, p_supconst, p_area_util, p_num_cajones, p_actividad, p_uso_suelo, p_desc_uso, p_zona, p_subzona, p_dictamen, p_capturista, p_fecha)
    RETURNING id INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro creado exitosamente'::TEXT, v_new_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_dictamenes_create IS
'Crea nuevo dictamen. Tabla: comun.dictamenes';


-- ============================================================
-- SP: sp_dictamenes_update
-- ============================================================
-- Descripción: Actualiza dictamen
-- Tabla: comun.dictamenes
-- Tipo: UPDATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_dictamenes_update(
    p_id_dictamen INTEGER,
    p_id_giro INTEGER,
    p_propietario CHARACTER VARYING(100),
    p_domicilio CHARACTER VARYING(100),
    p_no_exterior CHARACTER VARYING(5),
    p_no_interior CHARACTER VARYING(5),
    p_supconst DOUBLE PRECISION,
    p_area_util DOUBLE PRECISION,
    p_num_cajones INTEGER,
    p_actividad CHARACTER VARYING(100),
    p_uso_suelo CHARACTER VARYING(200),
    p_desc_uso CHARACTER VARYING(120),
    p_zona INTEGER,
    p_subzona INTEGER,
    p_dictamen CHARACTER VARYING(1),
    p_capturista CHARACTER VARYING(10),
    p_fecha DATE
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE comun.dictamenes
    SET
        id_dictamen = p_id_dictamen,
        id_giro = p_id_giro,
        propietario = p_propietario,
        domicilio = p_domicilio,
        no_exterior = p_no_exterior,
        no_interior = p_no_interior,
        supconst = p_supconst,
        area_util = p_area_util,
        num_cajones = p_num_cajones,
        actividad = p_actividad,
        uso_suelo = p_uso_suelo,
        desc_uso = p_desc_uso,
        zona = p_zona,
        subzona = p_subzona,
        dictamen = p_dictamen,
        capturista = p_capturista,
        fecha = p_fecha
    WHERE id = p_id;

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

COMMENT ON FUNCTION sp_dictamenes_update IS
'Actualiza dictamen. Tabla: comun.dictamenes';


-- ============================================================
-- SP: sp_create_constancia
-- ============================================================
-- Descripción: Crea nueva constancia
-- Tabla: public.constancias
-- Tipo: CREATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_create_constancia(
    p_axo INTEGER,
    p_folio INTEGER,
    p_id_licencia INTEGER,
    p_solicita CHARACTER VARYING(50),
    p_partidapago CHARACTER VARYING(25),
    p_domicilio CHARACTER VARYING(65),
    p_tipo SMALLINT,
    p_observacion CHARACTER VARYING(100),
    p_vigente CHARACTER VARYING(1),
    p_feccap DATE,
    p_capturista CHARACTER VARYING(10)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    axo INTEGER
)
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    INSERT INTO public.constancias (axo, folio, id_licencia, solicita, partidapago, domicilio, tipo, observacion, vigente, feccap, capturista)
    VALUES (p_axo, p_folio, p_id_licencia, p_solicita, p_partidapago, p_domicilio, p_tipo, p_observacion, p_vigente, p_feccap, p_capturista)
    RETURNING axo INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro creado exitosamente'::TEXT, v_new_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION sp_create_constancia IS
'Crea nueva constancia. Tabla: public.constancias';


-- ============================================================
-- SP: sp_update_constancia
-- ============================================================
-- Descripción: Actualiza constancia
-- Tabla: public.constancias
-- Tipo: UPDATE
-- ============================================================

CREATE OR REPLACE FUNCTION sp_update_constancia(
    p_axo INTEGER,
    p_folio INTEGER,
    p_id_licencia INTEGER,
    p_solicita CHARACTER VARYING(50),
    p_partidapago CHARACTER VARYING(25),
    p_domicilio CHARACTER VARYING(65),
    p_tipo SMALLINT,
    p_observacion CHARACTER VARYING(100),
    p_vigente CHARACTER VARYING(1),
    p_feccap DATE,
    p_capturista CHARACTER VARYING(10)
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE public.constancias
    SET
        folio = p_folio,
        id_licencia = p_id_licencia,
        solicita = p_solicita,
        partidapago = p_partidapago,
        domicilio = p_domicilio,
        tipo = p_tipo,
        observacion = p_observacion,
        vigente = p_vigente,
        feccap = p_feccap,
        capturista = p_capturista
    WHERE axo = p_axo;

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

COMMENT ON FUNCTION sp_update_constancia IS
'Actualiza constancia. Tabla: public.constancias';


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
