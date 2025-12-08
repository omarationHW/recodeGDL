-- ============================================================================
-- COMPONENTE: BloquearTramitefrm
-- MODULO: padron_licencias
-- DESCRIPCION: Stored Procedures para bloqueo y desbloqueo de tramites
-- SCHEMA: comun
-- FECHA: 2025-11-20
-- ============================================================================

-- ============================================================================
-- SP 1: sp_bloquear_tramite_get_tramite
-- DESCRIPCION: Obtiene informacion completa del tramite con validaciones de bloqueo
-- ============================================================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_tramite_get_tramite(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    id_tramite INTEGER,
    folio INTEGER,
    propietario VARCHAR,
    rfc VARCHAR,
    actividad TEXT,
    ubicacion TEXT,
    estatus VARCHAR,
    estatus_desc VARCHAR,
    bloqueado BOOLEAN,
    puede_bloquearse BOOLEAN,
    mensaje_validacion TEXT,
    fecha_bloqueo TIMESTAMP,
    usuario_bloqueo VARCHAR,
    motivo_bloqueo TEXT,
    tipo_bloqueo VARCHAR,
    id_giro INTEGER,
    fecha_registro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id_tramite,
        t.folio,
        COALESCE(t.propietario, t.denominacion, 'SIN NOMBRE') as propietario,
        t.rfc,
        COALESCE(g.descripcion, 'SIN GIRO') as actividad,
        TRIM(
            COALESCE(c.descripcion, '') || ' ' ||
            COALESCE(t.ubicacion, '') || ' #' ||
            COALESCE(t.numext_ubic::TEXT, 'S/N')
        ) as ubicacion,
        t.estatus,
        CASE t.estatus
            WHEN 'P' THEN 'EN PROCESO'
            WHEN 'A' THEN 'AUTORIZADO'
            WHEN 'R' THEN 'RECHAZADO'
            WHEN 'C' THEN 'CANCELADO'
            WHEN 'T' THEN 'TERMINADO'
            WHEN 'S' THEN 'SUSPENDIDO'
            ELSE 'DESCONOCIDO'
        END as estatus_desc,
        COALESCE(t.bloqueado, FALSE) as bloqueado,
        CASE
            WHEN t.estatus IN ('C', 'T') THEN FALSE
            WHEN COALESCE(t.bloqueado, FALSE) = TRUE THEN FALSE
            WHEN t.estatus NOT IN ('P', 'A', 'S') THEN FALSE
            ELSE TRUE
        END as puede_bloquearse,
        CASE
            WHEN t.estatus = 'C' THEN 'Tramite cancelado - No se puede bloquear'
            WHEN t.estatus = 'T' THEN 'Tramite terminado - No se puede bloquear'
            WHEN t.estatus = 'R' THEN 'Tramite rechazado - No se puede bloquear'
            WHEN COALESCE(t.bloqueado, FALSE) = TRUE THEN 'Tramite ya bloqueado'
            WHEN t.estatus IN ('P', 'A', 'S') THEN 'Tramite disponible para bloqueo'
            ELSE 'Estado no valido para bloqueo'
        END as mensaje_validacion,
        t.fecha_bloqueo,
        t.usuario_bloqueo,
        t.motivo_bloqueo,
        t.tipo_bloqueo,
        t.id_giro,
        t.fecha_registro
    FROM comun.tramites t
    LEFT JOIN comun.c_giros g ON t.id_giro = g.id_giro
    LEFT JOIN comun.c_colonias c ON t.id_colonia = c.id_colonia
    WHERE t.id_tramite = p_id_tramite;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tramite con ID % no existe', p_id_tramite;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_tramite_get_tramite(INTEGER) IS
'Obtiene informacion completa del tramite con validaciones de bloqueo';

-- ============================================================================
-- SP 2: sp_bloquear_tramite_get_giro
-- DESCRIPCION: Obtiene informacion del giro asociado al tramite
-- ============================================================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_tramite_get_giro(
    p_id_giro INTEGER
)
RETURNS TABLE(
    id_giro INTEGER,
    clave VARCHAR,
    descripcion VARCHAR,
    clasificacion VARCHAR,
    requiere_dictamen BOOLEAN,
    requiere_inspeccion BOOLEAN,
    vigente BOOLEAN,
    tipo_giro VARCHAR,
    riesgo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        g.clave,
        g.descripcion,
        COALESCE(g.clasificacion, 'NO ESPECIFICADA') as clasificacion,
        COALESCE(g.requiere_dictamen, FALSE) as requiere_dictamen,
        COALESCE(g.requiere_inspeccion, FALSE) as requiere_inspeccion,
        COALESCE(g.vigente, TRUE) as vigente,
        COALESCE(g.tipo_giro, 'GENERAL') as tipo_giro,
        COALESCE(g.riesgo, 'BAJO') as riesgo
    FROM comun.c_giros g
    WHERE g.id_giro = p_id_giro;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Giro con ID % no existe', p_id_giro;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_tramite_get_giro(INTEGER) IS
'Obtiene informacion del giro asociado al tramite';

-- ============================================================================
-- SP 3: sp_bloquear_tramite_get_bloqueos
-- DESCRIPCION: Obtiene historial de bloqueos/desbloqueos del tramite
-- ============================================================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_tramite_get_bloqueos(
    p_id_tramite INTEGER DEFAULT NULL,
    p_fecha_inicio DATE DEFAULT NULL,
    p_fecha_fin DATE DEFAULT NULL,
    p_usuario VARCHAR DEFAULT NULL,
    p_tipo_bloqueo VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 100,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
    id_bloqueo INTEGER,
    id_tramite INTEGER,
    folio INTEGER,
    propietario VARCHAR,
    tipo_bloqueo VARCHAR,
    tipo_bloqueo_desc VARCHAR,
    motivo TEXT,
    fecha_accion TIMESTAMP,
    usuario VARCHAR,
    accion VARCHAR,
    accion_desc VARCHAR,
    vigente BOOLEAN,
    fecha_desbloqueo TIMESTAMP,
    usuario_desbloqueo VARCHAR,
    motivo_desbloqueo TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.id_bloqueo,
        b.id_tramite,
        t.folio,
        COALESCE(t.propietario, t.denominacion, 'SIN NOMBRE') as propietario,
        b.tipo_bloqueo,
        CASE b.tipo_bloqueo
            WHEN 'ADM' THEN 'ADMINISTRATIVO'
            WHEN 'JUD' THEN 'JUDICIAL'
            WHEN 'FIS' THEN 'FISCAL'
            WHEN 'TEC' THEN 'TECNICO'
            WHEN 'SEG' THEN 'SEGURIDAD'
            ELSE 'OTROS'
        END as tipo_bloqueo_desc,
        b.motivo,
        b.fecha_accion,
        b.usuario,
        b.accion,
        CASE b.accion
            WHEN 'BLOQUEO' THEN 'BLOQUEADO'
            WHEN 'DESBLOQUEO' THEN 'DESBLOQUEADO'
            ELSE 'DESCONOCIDA'
        END as accion_desc,
        CASE
            WHEN b.accion = 'BLOQUEO' AND t.bloqueado = TRUE THEN TRUE
            ELSE FALSE
        END as vigente,
        b.fecha_desbloqueo,
        b.usuario_desbloqueo,
        b.motivo_desbloqueo
    FROM comun.bloqueos_tramites b
    INNER JOIN comun.tramites t ON b.id_tramite = t.id_tramite
    WHERE
        (p_id_tramite IS NULL OR b.id_tramite = p_id_tramite)
        AND (p_fecha_inicio IS NULL OR b.fecha_accion::DATE >= p_fecha_inicio)
        AND (p_fecha_fin IS NULL OR b.fecha_accion::DATE <= p_fecha_fin)
        AND (p_usuario IS NULL OR b.usuario ILIKE '%' || p_usuario || '%')
        AND (p_tipo_bloqueo IS NULL OR b.tipo_bloqueo = p_tipo_bloqueo)
    ORDER BY b.fecha_accion DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_tramite_get_bloqueos(INTEGER, DATE, DATE, VARCHAR, VARCHAR, INTEGER, INTEGER) IS
'Obtiene historial de bloqueos/desbloqueos del tramite con filtros opcionales';

-- ============================================================================
-- SP 4: sp_bloquear_tramite_bloquear
-- DESCRIPCION: Bloquea un tramite con validaciones completas
-- ============================================================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_tramite_bloquear(
    p_id_tramite INTEGER,
    p_tipo_bloqueo VARCHAR,
    p_motivo TEXT,
    p_usuario VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_tramite INTEGER,
    folio INTEGER,
    id_bloqueo INTEGER
) AS $$
DECLARE
    v_tramite RECORD;
    v_id_bloqueo INTEGER;
    v_tipo_bloqueo_valido BOOLEAN;
BEGIN
    -- Validar parametros obligatorios
    IF p_id_tramite IS NULL THEN
        RETURN QUERY SELECT FALSE, 'ID de tramite es obligatorio'::TEXT, NULL::INTEGER, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_tipo_bloqueo IS NULL OR TRIM(p_tipo_bloqueo) = '' THEN
        RETURN QUERY SELECT FALSE, 'Tipo de bloqueo es obligatorio'::TEXT, p_id_tramite, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT FALSE, 'Motivo de bloqueo es obligatorio'::TEXT, p_id_tramite, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT FALSE, 'Usuario es obligatorio'::TEXT, p_id_tramite, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar tipo de bloqueo
    SELECT EXISTS(
        SELECT 1 FROM comun.c_tipo_bloqueo
        WHERE clave = p_tipo_bloqueo AND vigente = TRUE
    ) INTO v_tipo_bloqueo_valido;

    IF NOT v_tipo_bloqueo_valido THEN
        RETURN QUERY SELECT FALSE, 'Tipo de bloqueo no valido o no vigente'::TEXT, p_id_tramite, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Obtener informacion del tramite
    SELECT
        t.id_tramite,
        t.folio,
        t.estatus,
        t.bloqueado
    INTO v_tramite
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Tramite no existe'::TEXT, p_id_tramite, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar estatus del tramite
    IF v_tramite.estatus IN ('C', 'T') THEN
        RETURN QUERY SELECT
            FALSE,
            'Tramite ' || CASE v_tramite.estatus WHEN 'C' THEN 'cancelado' ELSE 'terminado' END || ' - No se puede bloquear'::TEXT,
            p_id_tramite,
            v_tramite.folio,
            NULL::INTEGER;
        RETURN;
    END IF;

    IF v_tramite.estatus = 'R' THEN
        RETURN QUERY SELECT FALSE, 'Tramite rechazado - No se puede bloquear'::TEXT, p_id_tramite, v_tramite.folio, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que no este ya bloqueado
    IF COALESCE(v_tramite.bloqueado, FALSE) = TRUE THEN
        RETURN QUERY SELECT FALSE, 'Tramite ya esta bloqueado'::TEXT, p_id_tramite, v_tramite.folio, NULL::INTEGER;
        RETURN;
    END IF;

    -- Actualizar tramite como bloqueado
    UPDATE comun.tramites
    SET
        bloqueado = TRUE,
        fecha_bloqueo = NOW(),
        usuario_bloqueo = p_usuario,
        tipo_bloqueo = p_tipo_bloqueo,
        motivo_bloqueo = p_motivo
    WHERE id_tramite = p_id_tramite;

    -- Registrar en historial de bloqueos
    INSERT INTO comun.bloqueos_tramites (
        id_tramite,
        tipo_bloqueo,
        motivo,
        fecha_accion,
        usuario,
        accion
    ) VALUES (
        p_id_tramite,
        p_tipo_bloqueo,
        p_motivo,
        NOW(),
        p_usuario,
        'BLOQUEO'
    )
    RETURNING id_bloqueo INTO v_id_bloqueo;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        TRUE,
        'Tramite bloqueado exitosamente'::TEXT,
        p_id_tramite,
        v_tramite.folio,
        v_id_bloqueo;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al bloquear tramite: ' || SQLERRM::TEXT,
            p_id_tramite,
            NULL::INTEGER,
            NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_tramite_bloquear(INTEGER, VARCHAR, TEXT, VARCHAR) IS
'Bloquea un tramite con validaciones completas y registro en historial';

-- ============================================================================
-- SP 5: sp_bloquear_tramite_desbloquear
-- DESCRIPCION: Desbloquea un tramite con validaciones completas
-- ============================================================================
CREATE OR REPLACE FUNCTION comun.sp_bloquear_tramite_desbloquear(
    p_id_tramite INTEGER,
    p_motivo TEXT,
    p_usuario VARCHAR
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_tramite INTEGER,
    folio INTEGER,
    id_bloqueo INTEGER
) AS $$
DECLARE
    v_tramite RECORD;
    v_id_bloqueo INTEGER;
    v_tipo_bloqueo_anterior VARCHAR;
BEGIN
    -- Validar parametros obligatorios
    IF p_id_tramite IS NULL THEN
        RETURN QUERY SELECT FALSE, 'ID de tramite es obligatorio'::TEXT, NULL::INTEGER, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_motivo IS NULL OR TRIM(p_motivo) = '' THEN
        RETURN QUERY SELECT FALSE, 'Motivo de desbloqueo es obligatorio'::TEXT, p_id_tramite, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    IF p_usuario IS NULL OR TRIM(p_usuario) = '' THEN
        RETURN QUERY SELECT FALSE, 'Usuario es obligatorio'::TEXT, p_id_tramite, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Obtener informacion del tramite
    SELECT
        t.id_tramite,
        t.folio,
        t.estatus,
        t.bloqueado,
        t.tipo_bloqueo
    INTO v_tramite
    FROM comun.tramites t
    WHERE t.id_tramite = p_id_tramite;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Tramite no existe'::TEXT, p_id_tramite, NULL::INTEGER, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validar que este bloqueado
    IF COALESCE(v_tramite.bloqueado, FALSE) = FALSE THEN
        RETURN QUERY SELECT FALSE, 'Tramite no esta bloqueado'::TEXT, p_id_tramite, v_tramite.folio, NULL::INTEGER;
        RETURN;
    END IF;

    -- Guardar tipo de bloqueo anterior
    v_tipo_bloqueo_anterior := v_tramite.tipo_bloqueo;

    -- Actualizar tramite como desbloqueado
    UPDATE comun.tramites
    SET
        bloqueado = FALSE,
        fecha_desbloqueo = NOW(),
        usuario_desbloqueo = p_usuario,
        motivo_desbloqueo = p_motivo
    WHERE id_tramite = p_id_tramite;

    -- Registrar en historial de bloqueos
    INSERT INTO comun.bloqueos_tramites (
        id_tramite,
        tipo_bloqueo,
        motivo,
        fecha_accion,
        usuario,
        accion,
        fecha_desbloqueo,
        usuario_desbloqueo,
        motivo_desbloqueo
    ) VALUES (
        p_id_tramite,
        v_tipo_bloqueo_anterior,
        p_motivo,
        NOW(),
        p_usuario,
        'DESBLOQUEO',
        NOW(),
        p_usuario,
        p_motivo
    )
    RETURNING id_bloqueo INTO v_id_bloqueo;

    -- Actualizar registro de bloqueo anterior si existe
    UPDATE comun.bloqueos_tramites
    SET
        fecha_desbloqueo = NOW(),
        usuario_desbloqueo = p_usuario,
        motivo_desbloqueo = p_motivo
    WHERE id_tramite = p_id_tramite
        AND accion = 'BLOQUEO'
        AND fecha_desbloqueo IS NULL;

    -- Retornar resultado exitoso
    RETURN QUERY SELECT
        TRUE,
        'Tramite desbloqueado exitosamente'::TEXT,
        p_id_tramite,
        v_tramite.folio,
        v_id_bloqueo;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT
            FALSE,
            'Error al desbloquear tramite: ' || SQLERRM::TEXT,
            p_id_tramite,
            NULL::INTEGER,
            NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_bloquear_tramite_desbloquear(INTEGER, TEXT, VARCHAR) IS
'Desbloquea un tramite con validaciones completas y registro en historial';

-- ============================================================================
-- FIN DE SCRIPT
-- Total de Stored Procedures: 5
-- ============================================================================
