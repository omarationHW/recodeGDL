-- ============================================
-- STORED PROCEDURES FOR INFORMIX COMPATIBILITY
-- Component: modlicfrm.vue
-- Base: padron_licencias
-- Description: Procedures for license modification
-- ============================================

-- 1. sp_buscar_licencias_modificar - Search licenses for modification
DROP PROCEDURE IF EXISTS sp_buscar_licencias_modificar;

CREATE PROCEDURE sp_buscar_licencias_modificar(
    p_numero_licencia VARCHAR(50),
    p_propietario VARCHAR(255),
    p_actividad VARCHAR(255),
    p_estado VARCHAR(20),
    p_limite INTEGER,
    p_offset INTEGER
)
RETURNING
    INTEGER AS id_licencia,
    VARCHAR(50) AS numero_licencia,
    VARCHAR(255) AS propietario,
    VARCHAR(255) AS nombre_completo,
    VARCHAR(255) AS actividad,
    VARCHAR(255) AS giro,
    VARCHAR(500) AS direccion_completa,
    VARCHAR(255) AS colonia,
    INTEGER AS zona,
    VARCHAR(20) AS estado,
    DATE AS fecha_otorgamiento,
    DATE AS fecha_vencimiento,
    VARCHAR(20) AS rfc,
    DECIMAL(12,2) AS inversion,
    INTEGER AS num_empleados,
    VARCHAR(100) AS telefono,
    VARCHAR(255) AS email,
    CHAR(1) AS permite_modificacion,
    VARCHAR(255) AS motivo_bloqueo,
    INTEGER AS total_registros;

    DEFINE v_id_licencia INTEGER;
    DEFINE v_numero_licencia VARCHAR(50);
    DEFINE v_propietario VARCHAR(255);
    DEFINE v_nombre_completo VARCHAR(255);
    DEFINE v_actividad VARCHAR(255);
    DEFINE v_giro VARCHAR(255);
    DEFINE v_direccion_completa VARCHAR(500);
    DEFINE v_colonia VARCHAR(255);
    DEFINE v_zona INTEGER;
    DEFINE v_estado VARCHAR(20);
    DEFINE v_fecha_otorgamiento DATE;
    DEFINE v_fecha_vencimiento DATE;
    DEFINE v_rfc VARCHAR(20);
    DEFINE v_inversion DECIMAL(12,2);
    DEFINE v_num_empleados INTEGER;
    DEFINE v_telefono VARCHAR(100);
    DEFINE v_email VARCHAR(255);
    DEFINE v_permite_modificacion CHAR(1);
    DEFINE v_motivo_bloqueo VARCHAR(255);
    DEFINE v_total INTEGER;

    -- Count total records
    SELECT COUNT(*)
    INTO v_total
    FROM licencias l
    INNER JOIN c_giros g ON l.id_giro = g.id_giro
    WHERE (p_numero_licencia IS NULL OR l.licencia LIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR l.propietario LIKE '%' || p_propietario || '%')
      AND (p_actividad IS NULL OR l.actividad LIKE '%' || p_actividad || '%')
      AND (p_estado IS NULL OR l.vigente = p_estado)
      AND l.vigente IN ('V', 'C'); -- Solo vigentes o condicionadas

    -- Return paginated results
    FOREACH SELECT
        l.id_licencia,
        l.licencia,
        l.propietario,
        TRIM(l.propietario || ' ' || NVL(l.primer_ap, '') || ' ' || NVL(l.segundo_ap, '')),
        l.actividad,
        g.descripcion,
        TRIM(l.ubicacion || ' ' || NVL(l.numext_ubic, '') || ' ' || NVL(l.letraext_ubic, '') ||
             ', Col. ' || NVL(l.colonia_ubic, '')),
        l.colonia_ubic,
        l.zona,
        CASE
            WHEN l.vigente = 'V' THEN 'VIGENTE'
            WHEN l.vigente = 'C' THEN 'CONDICIONADA'
            WHEN l.vigente = 'S' THEN 'SUSPENDIDA'
            ELSE 'OTRO'
        END,
        l.fecha_otorgamiento,
        l.fecha_vencimiento,
        NVL(l.rfc, ''),
        NVL(l.inversion, 0),
        NVL(l.num_empleados, 0),
        NVL(l.telefono_prop, ''),
        NVL(l.email, ''),
        CASE
            WHEN l.bloqueado > 0 THEN 'N'
            WHEN l.vigente = 'S' THEN 'N'
            ELSE 'S'
        END,
        CASE
            WHEN l.bloqueado > 0 THEN 'Licencia bloqueada'
            WHEN l.vigente = 'S' THEN 'Licencia suspendida'
            ELSE ''
        END
    INTO
        v_id_licencia, v_numero_licencia, v_propietario, v_nombre_completo,
        v_actividad, v_giro, v_direccion_completa, v_colonia, v_zona,
        v_estado, v_fecha_otorgamiento, v_fecha_vencimiento, v_rfc,
        v_inversion, v_num_empleados, v_telefono, v_email, v_permite_modificacion,
        v_motivo_bloqueo
    FROM licencias l
    INNER JOIN c_giros g ON l.id_giro = g.id_giro
    WHERE (p_numero_licencia IS NULL OR l.licencia LIKE '%' || p_numero_licencia || '%')
      AND (p_propietario IS NULL OR l.propietario LIKE '%' || p_propietario || '%')
      AND (p_actividad IS NULL OR l.actividad LIKE '%' || p_actividad || '%')
      AND (p_estado IS NULL OR l.vigente = p_estado)
      AND l.vigente IN ('V', 'C')
    ORDER BY l.licencia
    SKIP p_offset
    FIRST p_limite

        RETURN v_id_licencia, v_numero_licencia, v_propietario, v_nombre_completo,
               v_actividad, v_giro, v_direccion_completa, v_colonia, v_zona,
               v_estado, v_fecha_otorgamiento, v_fecha_vencimiento, v_rfc,
               v_inversion, v_num_empleados, v_telefono, v_email, v_permite_modificacion,
               v_motivo_bloqueo, v_total
        WITH RESUME;

    END FOREACH;

END PROCEDURE;

-- ============================================

-- 2. sp_modificar_licencia - Modify license data
DROP PROCEDURE IF EXISTS sp_modificar_licencia;

CREATE PROCEDURE sp_modificar_licencia(
    p_id_licencia INTEGER,
    p_propietario VARCHAR(255),
    p_primer_ap VARCHAR(100),
    p_segundo_ap VARCHAR(100),
    p_rfc VARCHAR(20),
    p_actividad VARCHAR(255),
    p_id_giro INTEGER,
    p_ubicacion VARCHAR(255),
    p_numext_ubic INTEGER,
    p_letraext_ubic VARCHAR(5),
    p_numint_ubic VARCHAR(10),
    p_letraint_ubic VARCHAR(5),
    p_colonia_ubic VARCHAR(255),
    p_telefono_prop VARCHAR(100),
    p_email VARCHAR(255),
    p_inversion DECIMAL(12,2),
    p_num_empleados INTEGER,
    p_observaciones_modificacion VARCHAR(500),
    p_usuario_modifica VARCHAR(100)
)
RETURNING
    VARCHAR(50) AS status,
    VARCHAR(255) AS mensaje,
    VARCHAR(100) AS folio_modificacion;

    DEFINE v_existe INTEGER;
    DEFINE v_estado VARCHAR(20);
    DEFINE v_bloqueado INTEGER;
    DEFINE v_folio_modificacion VARCHAR(100);
    DEFINE v_numero_licencia VARCHAR(50);

    -- Check if license exists and can be modified
    SELECT COUNT(*), MAX(vigente), MAX(bloqueado), MAX(licencia)
    INTO v_existe, v_estado, v_bloqueado, v_numero_licencia
    FROM licencias
    WHERE id_licencia = p_id_licencia;

    IF v_existe = 0 THEN
        RETURN 'ERROR', 'Licencia no encontrada', '' WITH RESUME;
    END IF;

    IF v_estado = 'S' THEN
        RETURN 'ERROR', 'No se puede modificar una licencia suspendida', '' WITH RESUME;
    END IF;

    IF v_bloqueado > 0 THEN
        RETURN 'ERROR', 'No se puede modificar una licencia bloqueada', '' WITH RESUME;
    END IF;

    -- Generate modification folio
    LET v_folio_modificacion = 'MOD-' || v_numero_licencia || '-' ||
                              YEAR(TODAY) || MONTH(TODAY) || DAY(TODAY) ||
                              HOUR(CURRENT) || MINUTE(CURRENT);

    -- Create modification record
    INSERT INTO modificaciones_licencias (
        folio_modificacion,
        id_licencia,
        numero_licencia,
        propietario_anterior,
        propietario_nuevo,
        actividad_anterior,
        actividad_nueva,
        giro_anterior,
        giro_nuevo,
        ubicacion_anterior,
        ubicacion_nueva,
        telefono_anterior,
        telefono_nuevo,
        email_anterior,
        email_nuevo,
        inversion_anterior,
        inversion_nueva,
        empleados_anterior,
        empleados_nuevo,
        observaciones,
        usuario_modifica,
        fecha_modificacion,
        estado_modificacion
    )
    SELECT
        v_folio_modificacion,
        p_id_licencia,
        v_numero_licencia,
        l.propietario,
        p_propietario,
        l.actividad,
        p_actividad,
        l.id_giro,
        p_id_giro,
        l.ubicacion,
        p_ubicacion,
        l.telefono_prop,
        p_telefono_prop,
        l.email,
        p_email,
        l.inversion,
        p_inversion,
        l.num_empleados,
        p_num_empleados,
        p_observaciones_modificacion,
        p_usuario_modifica,
        TODAY,
        'APLICADA'
    FROM licencias l
    WHERE l.id_licencia = p_id_licencia;

    -- Update license with new data
    UPDATE licencias
    SET propietario = p_propietario,
        primer_ap = p_primer_ap,
        segundo_ap = p_segundo_ap,
        rfc = p_rfc,
        actividad = p_actividad,
        id_giro = p_id_giro,
        ubicacion = p_ubicacion,
        numext_ubic = p_numext_ubic,
        letraext_ubic = p_letraext_ubic,
        numint_ubic = p_numint_ubic,
        letraint_ubic = p_letraint_ubic,
        colonia_ubic = p_colonia_ubic,
        telefono_prop = p_telefono_prop,
        email = p_email,
        inversion = p_inversion,
        num_empleados = p_num_empleados,
        fecha_modificacion = TODAY,
        usuario_modifica = p_usuario_modifica
    WHERE id_licencia = p_id_licencia;

    IF SQLCA.SQLCODE = 0 THEN
        RETURN 'SUCCESS', 'Licencia modificada exitosamente', v_folio_modificacion WITH RESUME;
    ELSE
        RETURN 'ERROR', 'Error al modificar la licencia', '' WITH RESUME;
    END IF;

END PROCEDURE;

-- ============================================

-- 3. sp_obtener_licencia_detalle - Get license details for modification
DROP PROCEDURE IF EXISTS sp_obtener_licencia_detalle;

CREATE PROCEDURE sp_obtener_licencia_detalle(p_id_licencia INTEGER)
RETURNING
    INTEGER AS id_licencia,
    VARCHAR(50) AS numero_licencia,
    VARCHAR(255) AS propietario,
    VARCHAR(100) AS primer_ap,
    VARCHAR(100) AS segundo_ap,
    VARCHAR(20) AS rfc,
    VARCHAR(20) AS curp,
    VARCHAR(255) AS actividad,
    INTEGER AS id_giro,
    VARCHAR(255) AS giro_descripcion,
    VARCHAR(255) AS ubicacion,
    INTEGER AS numext_ubic,
    VARCHAR(5) AS letraext_ubic,
    VARCHAR(10) AS numint_ubic,
    VARCHAR(5) AS letraint_ubic,
    VARCHAR(255) AS colonia_ubic,
    INTEGER AS cp,
    INTEGER AS zona,
    INTEGER AS subzona,
    VARCHAR(100) AS telefono_prop,
    VARCHAR(255) AS email,
    DECIMAL(12,2) AS inversion,
    INTEGER AS num_empleados,
    INTEGER AS aforo,
    DECIMAL(10,2) AS sup_autorizada,
    INTEGER AS num_cajones,
    DATE AS fecha_otorgamiento,
    DATE AS fecha_vencimiento,
    VARCHAR(20) AS estado,
    INTEGER AS bloqueado,
    VARCHAR(255) AS motivo_bloqueo;

    DEFINE v_id_licencia INTEGER;
    DEFINE v_numero_licencia VARCHAR(50);
    DEFINE v_propietario VARCHAR(255);
    DEFINE v_primer_ap VARCHAR(100);
    DEFINE v_segundo_ap VARCHAR(100);
    DEFINE v_rfc VARCHAR(20);
    DEFINE v_curp VARCHAR(20);
    DEFINE v_actividad VARCHAR(255);
    DEFINE v_id_giro INTEGER;
    DEFINE v_giro_descripcion VARCHAR(255);
    DEFINE v_ubicacion VARCHAR(255);
    DEFINE v_numext_ubic INTEGER;
    DEFINE v_letraext_ubic VARCHAR(5);
    DEFINE v_numint_ubic VARCHAR(10);
    DEFINE v_letraint_ubic VARCHAR(5);
    DEFINE v_colonia_ubic VARCHAR(255);
    DEFINE v_cp INTEGER;
    DEFINE v_zona INTEGER;
    DEFINE v_subzona INTEGER;
    DEFINE v_telefono_prop VARCHAR(100);
    DEFINE v_email VARCHAR(255);
    DEFINE v_inversion DECIMAL(12,2);
    DEFINE v_num_empleados INTEGER;
    DEFINE v_aforo INTEGER;
    DEFINE v_sup_autorizada DECIMAL(10,2);
    DEFINE v_num_cajones INTEGER;
    DEFINE v_fecha_otorgamiento DATE;
    DEFINE v_fecha_vencimiento DATE;
    DEFINE v_estado VARCHAR(20);
    DEFINE v_bloqueado INTEGER;
    DEFINE v_motivo_bloqueo VARCHAR(255);

    SELECT
        l.id_licencia,
        l.licencia,
        l.propietario,
        NVL(l.primer_ap, ''),
        NVL(l.segundo_ap, ''),
        NVL(l.rfc, ''),
        NVL(l.curp, ''),
        l.actividad,
        l.id_giro,
        g.descripcion,
        l.ubicacion,
        NVL(l.numext_ubic, 0),
        NVL(l.letraext_ubic, ''),
        NVL(l.numint_ubic, ''),
        NVL(l.letraint_ubic, ''),
        NVL(l.colonia_ubic, ''),
        NVL(l.cp, 0),
        NVL(l.zona, 0),
        NVL(l.subzona, 0),
        NVL(l.telefono_prop, ''),
        NVL(l.email, ''),
        NVL(l.inversion, 0),
        NVL(l.num_empleados, 0),
        NVL(l.aforo, 0),
        NVL(l.sup_autorizada, 0),
        NVL(l.num_cajones, 0),
        l.fecha_otorgamiento,
        l.fecha_vencimiento,
        CASE
            WHEN l.vigente = 'V' THEN 'VIGENTE'
            WHEN l.vigente = 'C' THEN 'CONDICIONADA'
            WHEN l.vigente = 'S' THEN 'SUSPENDIDA'
            ELSE 'OTRO'
        END,
        NVL(l.bloqueado, 0),
        CASE
            WHEN l.bloqueado > 0 THEN 'Licencia bloqueada'
            WHEN l.vigente = 'S' THEN 'Licencia suspendida'
            ELSE ''
        END
    INTO
        v_id_licencia, v_numero_licencia, v_propietario, v_primer_ap, v_segundo_ap,
        v_rfc, v_curp, v_actividad, v_id_giro, v_giro_descripcion, v_ubicacion,
        v_numext_ubic, v_letraext_ubic, v_numint_ubic, v_letraint_ubic, v_colonia_ubic,
        v_cp, v_zona, v_subzona, v_telefono_prop, v_email, v_inversion, v_num_empleados,
        v_aforo, v_sup_autorizada, v_num_cajones, v_fecha_otorgamiento, v_fecha_vencimiento,
        v_estado, v_bloqueado, v_motivo_bloqueo
    FROM licencias l
    INNER JOIN c_giros g ON l.id_giro = g.id_giro
    WHERE l.id_licencia = p_id_licencia;

    IF SQLCA.SQLCODE = 0 THEN
        RETURN v_id_licencia, v_numero_licencia, v_propietario, v_primer_ap, v_segundo_ap,
               v_rfc, v_curp, v_actividad, v_id_giro, v_giro_descripcion, v_ubicacion,
               v_numext_ubic, v_letraext_ubic, v_numint_ubic, v_letraint_ubic, v_colonia_ubic,
               v_cp, v_zona, v_subzona, v_telefono_prop, v_email, v_inversion, v_num_empleados,
               v_aforo, v_sup_autorizada, v_num_cajones, v_fecha_otorgamiento, v_fecha_vencimiento,
               v_estado, v_bloqueado, v_motivo_bloqueo
        WITH RESUME;
    END IF;

END PROCEDURE;

-- ============================================

-- 4. sp_historial_modificaciones_licencia - Get modification history
DROP PROCEDURE IF EXISTS sp_historial_modificaciones_licencia;

CREATE PROCEDURE sp_historial_modificaciones_licencia(p_id_licencia INTEGER)
RETURNING
    INTEGER AS id,
    VARCHAR(100) AS folio_modificacion,
    DATE AS fecha_modificacion,
    VARCHAR(100) AS usuario_modifica,
    VARCHAR(500) AS observaciones,
    VARCHAR(30) AS estado_modificacion,
    VARCHAR(255) AS cambios_realizados;

    DEFINE v_id INTEGER;
    DEFINE v_folio_modificacion VARCHAR(100);
    DEFINE v_fecha_modificacion DATE;
    DEFINE v_usuario_modifica VARCHAR(100);
    DEFINE v_observaciones VARCHAR(500);
    DEFINE v_estado_modificacion VARCHAR(30);
    DEFINE v_cambios_realizados VARCHAR(255);

    FOREACH SELECT
        id,
        folio_modificacion,
        fecha_modificacion,
        usuario_modifica,
        NVL(observaciones, ''),
        estado_modificacion,
        'Propietario, Actividad, Ubicación y otros datos'
    INTO
        v_id, v_folio_modificacion, v_fecha_modificacion, v_usuario_modifica,
        v_observaciones, v_estado_modificacion, v_cambios_realizados
    FROM modificaciones_licencias
    WHERE id_licencia = p_id_licencia
    ORDER BY fecha_modificacion DESC

        RETURN v_id, v_folio_modificacion, v_fecha_modificacion, v_usuario_modifica,
               v_observaciones, v_estado_modificacion, v_cambios_realizados
        WITH RESUME;

    END FOREACH;

END PROCEDURE;