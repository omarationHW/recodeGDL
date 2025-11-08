-- =====================================================
-- CREAR SP: sp_registro_solicitud
-- Adaptado a la estructura EXISTENTE de comun.tramites
-- =====================================================

CREATE OR REPLACE FUNCTION comun.sp_registro_solicitud(
    p_tipo_tramite INTEGER,
    p_id_giro INTEGER,
    p_actividad VARCHAR,
    p_propietario VARCHAR,
    p_telefono VARCHAR,
    p_email VARCHAR DEFAULT NULL,
    p_calle VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL,
    p_cp VARCHAR DEFAULT NULL,
    p_numext VARCHAR DEFAULT NULL,
    p_numint VARCHAR DEFAULT NULL,
    p_letraext VARCHAR DEFAULT NULL,
    p_letraint VARCHAR DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL,
    p_sup_const NUMERIC(10,2) DEFAULT NULL,
    p_sup_autorizada NUMERIC(10,2) DEFAULT NULL,
    p_num_cajones INTEGER DEFAULT NULL,
    p_num_empleados INTEGER DEFAULT NULL,
    p_inversion NUMERIC(15,2) DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_curp VARCHAR DEFAULT NULL,
    p_especificaciones TEXT DEFAULT NULL,
    p_usuario VARCHAR DEFAULT 'sistema'
)
RETURNS TABLE (
    id_tramite INTEGER,
    folio INTEGER,
    fecha_registro DATE,
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_tramite INTEGER;
    v_folio INTEGER;
    v_fecha DATE;
    v_tipo_tramite_char CHAR(2);
BEGIN
    -- Obtener fecha actual
    v_fecha := CURRENT_DATE;

    -- Convertir tipo_tramite a CHAR(2)
    v_tipo_tramite_char := LPAD(p_tipo_tramite::TEXT, 2, '0');

    -- Insertar en tabla tramites (usando estructura existente)
    -- Nota: Algunos campos son CHAR con límites estrictos, se truncan si exceden
    INSERT INTO comun.tramites (
        tipo_tramite,
        id_giro,
        actividad,
        propietario,
        telefono_prop,
        email,
        ubicacion,
        colonia_ubic,
        cp,
        numext_ubic,
        numint_ubic,
        letraext_ubic,
        letraint_ubic,
        zona,
        subzona,
        sup_construida,
        sup_autorizada,
        num_cajones,
        num_empleados,
        inversion,
        rfc,
        curp,
        observaciones,
        estatus,
        feccap,
        capturista,
        bloqueado,
        dictamen,
        x,
        y,
        cvecuenta,
        recaud
    ) VALUES (
        v_tipo_tramite_char,
        p_id_giro,
        SUBSTRING(p_actividad, 1, 130),            -- CHAR(130)
        SUBSTRING(p_propietario, 1, 80),           -- CHAR(80)
        SUBSTRING(p_telefono, 1, 30),              -- CHAR(30)
        SUBSTRING(p_email, 1, 50),                 -- CHAR(50)
        SUBSTRING(p_calle, 1, 50),                 -- CHAR(50)
        SUBSTRING(p_colonia, 1, 25),               -- CHAR(25)
        p_cp::INTEGER,
        p_numext::INTEGER,
        SUBSTRING(p_numint, 1, 5),                 -- CHAR(5)
        SUBSTRING(p_letraext, 1, 3),               -- CHAR(3)
        SUBSTRING(p_letraint, 1, 3),               -- CHAR(3)
        p_zona,
        p_subzona,
        p_sup_const,
        p_sup_autorizada,
        p_num_cajones,
        p_num_empleados,
        p_inversion,
        SUBSTRING(p_rfc, 1, 13),                   -- CHAR(13)
        SUBSTRING(p_curp, 1, 18),                  -- CHAR(18)
        p_especificaciones,                        -- TEXT (sin límite)
        'A',              -- estatus: A=Activo (CHAR(1))
        v_fecha,
        SUBSTRING(p_usuario, 1, 10),               -- CHAR(10)
        0,                -- bloqueado: 0=No bloqueado
        0,                -- dictamen: 0=Sin dictamen
        0.00,             -- x coordenada
        0.00,             -- y coordenada
        0,                -- cvecuenta
        0                 -- recaud
    )
    RETURNING comun.tramites.id_tramite, comun.tramites.folio INTO v_id_tramite, v_folio;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        v_id_tramite,
        v_folio,
        v_fecha,
        TRUE::BOOLEAN,
        'Solicitud registrada exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        -- Retornar error
        RETURN QUERY SELECT
            NULL::INTEGER,
            NULL::INTEGER,
            NULL::DATE,
            FALSE::BOOLEAN,
            ('Error al registrar solicitud: ' || SQLERRM)::TEXT;
END;
$$;

-- =====================================================
-- SP para agregar documentos (tabla documentos legacy)
-- =====================================================

CREATE OR REPLACE FUNCTION comun.sp_agregar_documento(
    p_id_tramite INTEGER,
    p_tipo_documento VARCHAR,
    p_nombre_archivo VARCHAR,
    p_ruta_archivo VARCHAR,
    p_observaciones TEXT DEFAULT NULL,
    p_usuario VARCHAR DEFAULT 'sistema'
)
RETURNS TABLE (
    id_documento INTEGER,
    success BOOLEAN,
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_documentos_actual TEXT;
    v_nuevo_documento TEXT;
BEGIN
    -- Obtener documentos actuales del trámite
    SELECT documentos INTO v_documentos_actual
    FROM comun.tramites
    WHERE id_tramite = p_id_tramite;

    IF NOT FOUND THEN
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE::BOOLEAN,
            'Trámite no encontrado'::TEXT;
        RETURN;
    END IF;

    -- Crear entrada del nuevo documento
    v_nuevo_documento := p_tipo_documento || ': ' || p_nombre_archivo;

    -- Agregar al campo documentos (separado por coma)
    IF v_documentos_actual IS NULL OR v_documentos_actual = '' THEN
        v_documentos_actual := v_nuevo_documento;
    ELSE
        v_documentos_actual := v_documentos_actual || ', ' || v_nuevo_documento;
    END IF;

    -- Actualizar el trámite
    UPDATE comun.tramites
    SET documentos = v_documentos_actual
    WHERE id_tramite = p_id_tramite;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        p_id_tramite,
        TRUE::BOOLEAN,
        'Documento agregado exitosamente'::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        -- Retornar error
        RETURN QUERY SELECT
            NULL::INTEGER,
            FALSE::BOOLEAN,
            ('Error al agregar documento: ' || SQLERRM)::TEXT;
END;
$$;

-- =====================================================
-- PERMISOS
-- =====================================================

GRANT EXECUTE ON FUNCTION comun.sp_registro_solicitud TO refact;
GRANT EXECUTE ON FUNCTION comun.sp_agregar_documento TO refact;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON FUNCTION comun.sp_registro_solicitud IS 'Registra una nueva solicitud/trámite en el sistema. Adaptado a estructura legacy de comun.tramites';
COMMENT ON FUNCTION comun.sp_agregar_documento IS 'Agrega información de documento al campo documentos del trámite';

SELECT 'SPs creados exitosamente en esquema comun' AS resultado;
