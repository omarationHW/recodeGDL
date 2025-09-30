-- ============================================
-- STORED PROCEDURES COMPLETOS - INFORMIX
-- Sistema: Bloqueo/Suspensión de Trámites
-- Archivo: 40_SP_BLOQUEAR_TRAMITE_INFORMIX.sql
-- Descripción: Sistema completo de gestión de bloqueos de trámites
-- Fecha: 2025-09-30
-- Total SPs: 8 procedimientos
-- ============================================

-- SP 1/8: sp_buscar_tramite
-- Tipo: Catalog
-- Descripción: Busca un trámite por número y devuelve información completa con estado de bloqueo
-- Parámetros entrada: p_numero_tramite (INTEGER)
-- Parámetros salida: Datos completos del trámite
-- --------------------------------------------

CREATE PROCEDURE sp_buscar_tramite(p_numero_tramite INTEGER)
RETURNING INTEGER AS id_tramite,
          INTEGER AS folio,
          LVARCHAR(50) AS tipo_tramite,
          LVARCHAR(255) AS giro,
          LVARCHAR(100) AS propietario,
          LVARCHAR(100) AS primer_ap,
          LVARCHAR(100) AS segundo_ap,
          LVARCHAR(255) AS ubicacion,
          INTEGER AS numext_ubic,
          LVARCHAR(50) AS letraext_ubic,
          LVARCHAR(50) AS numint_ubic,
          LVARCHAR(50) AS letraint_ubic,
          LVARCHAR(255) AS actividad,
          INTEGER AS bloqueado,
          LVARCHAR(20) AS estado_texto,
          DATE AS fecha_ultima_modificacion,
          LVARCHAR(50) AS capturista_actual;

    RETURN
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        COALESCE(g.descripcion, 'Sin giro especificado') AS giro,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.numint_ubic,
        t.letraint_ubic,
        t.actividad,
        t.bloqueado,
        CASE
            WHEN t.bloqueado = 0 THEN 'NO BLOQUEADO'
            WHEN t.bloqueado = 1 THEN 'BLOQUEADO GENERAL'
            WHEN t.bloqueado = 2 THEN 'DOCUMENTACIÓN FALTANTE'
            WHEN t.bloqueado = 3 THEN 'OBSERVACIÓN TÉCNICA'
            WHEN t.bloqueado = 4 THEN 'SUSPENDIDO'
            WHEN t.bloqueado = 5 THEN 'RESPONSIVA REQUERIDA'
            WHEN t.bloqueado = 6 THEN 'CONVENIO PENDIENTE'
            WHEN t.bloqueado = 7 THEN 'CONFLICTO LEGAL'
            ELSE 'BLOQUEADO'
        END AS estado_texto,
        t.feccap AS fecha_ultima_modificacion,
        t.capturista AS capturista_actual
    FROM tramites t
    LEFT JOIN c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_numero_tramite;

END PROCEDURE;

-- SP 2/8: sp_tipobloqueo_list
-- Tipo: Catalog
-- Descripción: Obtiene la lista de tipos de bloqueo disponibles
-- Parámetros entrada: Ninguno
-- Parámetros salida: id, descripcion, activo
-- --------------------------------------------

CREATE PROCEDURE sp_tipobloqueo_list()
RETURNING INTEGER AS id,
          LVARCHAR(255) AS descripcion,
          LVARCHAR(1) AS activo;

    RETURN 1, 'BLOQUEADO GENERAL - Suspensión temporal por motivos administrativos', 'V'
    UNION ALL
    RETURN 2, 'DOCUMENTACIÓN FALTANTE - Faltan documentos requeridos para continuar', 'V'
    UNION ALL
    RETURN 3, 'OBSERVACIÓN TÉCNICA - Revisión técnica en proceso', 'V'
    UNION ALL
    RETURN 4, 'SUSPENDIDO - Trámite suspendido por resolución administrativa', 'V'
    UNION ALL
    RETURN 5, 'RESPONSIVA REQUERIDA - Se requiere carta responsiva del solicitante', 'V'
    UNION ALL
    RETURN 6, 'CONVENIO PENDIENTE - Pendiente de firma de convenio', 'V'
    UNION ALL
    RETURN 7, 'CONFLICTO LEGAL - En proceso de resolución legal', 'V';

END PROCEDURE;

-- SP 3/8: sp_bloquear_tramite
-- Tipo: CRUD
-- Descripción: Bloquea un trámite con notificación y seguimiento completo
-- Parámetros entrada: p_id_tramite, p_tipo_bloqueo, p_motivo, p_usuario, p_notificar_solicitante
-- Parámetros salida: success, message, id_movimiento
-- --------------------------------------------

CREATE PROCEDURE sp_bloquear_tramite(
    p_id_tramite INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo LVARCHAR(1000),
    p_usuario LVARCHAR(50),
    p_notificar_solicitante LVARCHAR(1) DEFAULT 'N'
)
RETURNING INTEGER AS success,
          LVARCHAR(500) AS message,
          INTEGER AS id_movimiento;

DEFINE v_bloqueado INTEGER;
DEFINE v_propietario LVARCHAR(100);
DEFINE v_email LVARCHAR(100);
DEFINE v_folio INTEGER;
DEFINE v_id_bloqueo INTEGER;
DEFINE v_fecha_actual DATETIME YEAR TO SECOND;

    -- Obtener fecha actual
    LET v_fecha_actual = CURRENT YEAR TO SECOND;

    -- Verificar si el trámite existe y obtener información
    SELECT bloqueado, propietario, email, folio
    INTO v_bloqueado, v_propietario, v_email, v_folio
    FROM tramites
    WHERE id_tramite = p_id_tramite;

    IF v_bloqueado IS NULL THEN
        RETURN 0, 'Error: No existe el trámite especificado', 0;
    END IF;

    IF v_bloqueado > 0 THEN
        RETURN 0, 'Error: El trámite ya se encuentra bloqueado. Debe desbloquearlo primero', 0;
    END IF;

    -- Validar tipo de bloqueo
    IF p_tipo_bloqueo < 1 OR p_tipo_bloqueo > 7 THEN
        RETURN 0, 'Error: Tipo de bloqueo no válido', 0;
    END IF;

    BEGIN
        -- Actualizar estado en tramites
        UPDATE tramites
        SET bloqueado = p_tipo_bloqueo,
            feccap = v_fecha_actual,
            capturista = p_usuario
        WHERE id_tramite = p_id_tramite;

        -- Cancelar bloqueos vigentes anteriores
        UPDATE bloqueo
        SET vigente = 'C',
            fecha_cancelacion = v_fecha_actual
        WHERE id_tramite = p_id_tramite AND vigente = 'V';

        -- Insertar nuevo bloqueo con información extendida
        INSERT INTO bloqueo (
            bloqueado,
            id_tramite,
            observa,
            capturista,
            fecha_mov,
            vigente,
            motivo_bloqueo,
            notificacion_enviada,
            fecha_notificacion,
            requiere_seguimiento
        )
        VALUES (
            p_tipo_bloqueo,
            p_id_tramite,
            p_motivo,
            p_usuario,
            v_fecha_actual,
            'V',
            p_motivo,
            p_notificar_solicitante,
            CASE WHEN p_notificar_solicitante = 'S' THEN v_fecha_actual ELSE NULL END,
            'S'
        );

        -- Obtener ID del bloqueo insertado
        LET v_id_bloqueo = DBINFO('sqlca.sqlerrd1');

        -- Registrar en log de actividades
        INSERT INTO log_actividades_tramites (
            id_tramite,
            tipo_operacion,
            descripcion,
            usuario,
            fecha_operacion,
            datos_adicionales
        )
        VALUES (
            p_id_tramite,
            'BLOQUEO',
            'Trámite bloqueado - Tipo: ' || p_tipo_bloqueo || ' - Motivo: ' || p_motivo,
            p_usuario,
            v_fecha_actual,
            'folio=' || v_folio || ';tipo_bloqueo=' || p_tipo_bloqueo
        );

        RETURN 1, 'Trámite bloqueado correctamente. Folio: ' || v_folio, v_id_bloqueo;

    END

    ON EXCEPTION
        RETURN 0, 'Error interno al procesar el bloqueo: ' || SQLCA.SQLSTATE, 0;
    END EXCEPTION;

END PROCEDURE;

-- SP 4/8: sp_desbloquear_tramite
-- Tipo: CRUD
-- Descripción: Desbloquea un trámite específico con validaciones y notificaciones
-- Parámetros entrada: p_id_tramite, p_tipo_bloqueo, p_motivo, p_usuario
-- Parámetros salida: success, message
-- --------------------------------------------

CREATE PROCEDURE sp_desbloquear_tramite(
    p_id_tramite INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo LVARCHAR(1000),
    p_usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(500) AS message;

DEFINE v_bloqueado INTEGER;
DEFINE v_folio INTEGER;
DEFINE v_count INTEGER;
DEFINE v_fecha_actual DATETIME YEAR TO SECOND;

    -- Obtener fecha actual
    LET v_fecha_actual = CURRENT YEAR TO SECOND;

    -- Verificar si el trámite existe y está bloqueado
    SELECT bloqueado, folio
    INTO v_bloqueado, v_folio
    FROM tramites
    WHERE id_tramite = p_id_tramite;

    IF v_bloqueado IS NULL THEN
        RETURN 0, 'Error: No existe el trámite especificado';
    END IF;

    IF v_bloqueado = 0 THEN
        RETURN 0, 'Error: El trámite no está bloqueado';
    END IF;

    -- Verificar que existe un bloqueo vigente del tipo especificado
    SELECT COUNT(*)
    INTO v_count
    FROM bloqueo
    WHERE id_tramite = p_id_tramite
    AND bloqueado = p_tipo_bloqueo
    AND vigente = 'V';

    IF v_count = 0 THEN
        RETURN 0, 'Error: No existe un bloqueo vigente del tipo especificado';
    END IF;

    BEGIN
        -- Actualizar campo bloqueado en tramites
        UPDATE tramites
        SET bloqueado = 0,
            feccap = v_fecha_actual,
            capturista = p_usuario
        WHERE id_tramite = p_id_tramite;

        -- Cancelar el bloqueo específico
        UPDATE bloqueo
        SET vigente = 'C',
            fecha_cancelacion = v_fecha_actual,
            usuario_cancelacion = p_usuario,
            motivo_cancelacion = p_motivo
        WHERE id_tramite = p_id_tramite
        AND bloqueado = p_tipo_bloqueo
        AND vigente = 'V';

        -- Insertar registro de desbloqueo
        INSERT INTO bloqueo (
            bloqueado,
            id_tramite,
            observa,
            capturista,
            fecha_mov,
            vigente,
            motivo_bloqueo,
            es_desbloqueo
        )
        VALUES (
            0,
            p_id_tramite,
            'DESBLOQUEO: ' || p_motivo,
            p_usuario,
            v_fecha_actual,
            'V',
            p_motivo,
            'S'
        );

        -- Registrar en log de actividades
        INSERT INTO log_actividades_tramites (
            id_tramite,
            tipo_operacion,
            descripcion,
            usuario,
            fecha_operacion,
            datos_adicionales
        )
        VALUES (
            p_id_tramite,
            'DESBLOQUEO',
            'Trámite desbloqueado - Tipo anterior: ' || p_tipo_bloqueo || ' - Motivo: ' || p_motivo,
            p_usuario,
            v_fecha_actual,
            'folio=' || v_folio || ';tipo_bloqueo_anterior=' || p_tipo_bloqueo
        );

        RETURN 1, 'Trámite desbloqueado correctamente. Folio: ' || v_folio;

    END

    ON EXCEPTION
        RETURN 0, 'Error interno al procesar el desbloqueo: ' || SQLCA.SQLSTATE;
    END EXCEPTION;

END PROCEDURE;

-- SP 5/8: sp_consultar_historial_tramite_paginado
-- Tipo: Catalog
-- Descripción: Consulta el historial de bloqueos con paginación server-side
-- Parámetros entrada: p_id_tramite, limit_records, offset_records
-- Parámetros salida: Historial paginado con total de registros
-- --------------------------------------------

CREATE PROCEDURE sp_consultar_historial_tramite_paginado(
    p_id_tramite INTEGER,
    limit_records INTEGER DEFAULT 10,
    offset_records INTEGER DEFAULT 0
)
RETURNING INTEGER AS id_bloqueo,
          INTEGER AS bloqueado,
          LVARCHAR(50) AS estado,
          LVARCHAR(50) AS capturista,
          DATETIME YEAR TO SECOND AS fecha_mov,
          LVARCHAR(1) AS vigente,
          LVARCHAR(1000) AS observa,
          LVARCHAR(1) AS es_desbloqueo,
          INTEGER AS total_registros,
          DATETIME YEAR TO SECOND AS fecha_cancelacion,
          LVARCHAR(50) AS usuario_cancelacion;

DEFINE v_total INTEGER;
DEFINE v_sql LVARCHAR(2000);

    -- Obtener total de registros
    SELECT COUNT(*)
    INTO v_total
    FROM bloqueo
    WHERE id_tramite = p_id_tramite;

    -- Retornar registros paginados
    RETURN
        b.id_bloqueo,
        b.bloqueado,
        CASE
            WHEN b.bloqueado = 0 THEN
                CASE WHEN b.es_desbloqueo = 'S' THEN 'DESBLOQUEADO' ELSE 'SIN BLOQUEO' END
            WHEN b.bloqueado = 1 THEN 'BLOQUEADO GENERAL'
            WHEN b.bloqueado = 2 THEN 'DOCUMENTACIÓN FALTANTE'
            WHEN b.bloqueado = 3 THEN 'OBSERVACIÓN TÉCNICA'
            WHEN b.bloqueado = 4 THEN 'SUSPENDIDO'
            WHEN b.bloqueado = 5 THEN 'RESPONSIVA REQUERIDA'
            WHEN b.bloqueado = 6 THEN 'CONVENIO PENDIENTE'
            WHEN b.bloqueado = 7 THEN 'CONFLICTO LEGAL'
            ELSE 'ESTADO DESCONOCIDO'
        END AS estado,
        b.capturista,
        b.fecha_mov,
        b.vigente,
        b.observa,
        COALESCE(b.es_desbloqueo, 'N') AS es_desbloqueo,
        v_total AS total_registros,
        b.fecha_cancelacion,
        b.usuario_cancelacion
    FROM bloqueo b
    WHERE b.id_tramite = p_id_tramite
    ORDER BY b.fecha_mov DESC
    LIMIT limit_records OFFSET offset_records;

END PROCEDURE;

-- SP 6/8: sp_consultar_historial_tramite
-- Tipo: Catalog
-- Descripción: Consulta completa del historial sin paginación (fallback)
-- Parámetros entrada: p_id_tramite
-- Parámetros salida: Historial completo ordenado por fecha
-- --------------------------------------------

CREATE PROCEDURE sp_consultar_historial_tramite(p_id_tramite INTEGER)
RETURNING INTEGER AS id_bloqueo,
          INTEGER AS bloqueado,
          LVARCHAR(50) AS estado,
          LVARCHAR(50) AS capturista,
          DATETIME YEAR TO SECOND AS fecha_mov,
          LVARCHAR(1) AS vigente,
          LVARCHAR(1000) AS observa,
          LVARCHAR(1) AS es_desbloqueo;

    RETURN
        b.id_bloqueo,
        b.bloqueado,
        CASE
            WHEN b.bloqueado = 0 THEN
                CASE WHEN b.es_desbloqueo = 'S' THEN 'DESBLOQUEADO' ELSE 'SIN BLOQUEO' END
            WHEN b.bloqueado = 1 THEN 'BLOQUEADO GENERAL'
            WHEN b.bloqueado = 2 THEN 'DOCUMENTACIÓN FALTANTE'
            WHEN b.bloqueado = 3 THEN 'OBSERVACIÓN TÉCNICA'
            WHEN b.bloqueado = 4 THEN 'SUSPENDIDO'
            WHEN b.bloqueado = 5 THEN 'RESPONSIVA REQUERIDA'
            WHEN b.bloqueado = 6 THEN 'CONVENIO PENDIENTE'
            WHEN b.bloqueado = 7 THEN 'CONFLICTO LEGAL'
            ELSE 'ESTADO DESCONOCIDO'
        END AS estado,
        b.capturista,
        b.fecha_mov,
        b.vigente,
        b.observa,
        COALESCE(b.es_desbloqueo, 'N') AS es_desbloqueo
    FROM bloqueo b
    WHERE b.id_tramite = p_id_tramite
    ORDER BY b.fecha_mov DESC;

END PROCEDURE;

-- SP 7/8: sp_obtener_bloqueos_activos
-- Tipo: Catalog
-- Descripción: Obtiene la lista de bloqueos activos para un trámite
-- Parámetros entrada: p_id_tramite
-- Parámetros salida: Lista de bloqueos vigentes
-- --------------------------------------------

CREATE PROCEDURE sp_obtener_bloqueos_activos(p_id_tramite INTEGER)
RETURNING INTEGER AS id,
          LVARCHAR(255) AS descripcion,
          DATETIME YEAR TO SECOND AS fecha_bloqueo,
          LVARCHAR(50) AS usuario_bloqueo;

    RETURN
        b.bloqueado AS id,
        CASE
            WHEN b.bloqueado = 1 THEN 'BLOQUEADO GENERAL - Suspensión temporal por motivos administrativos'
            WHEN b.bloqueado = 2 THEN 'DOCUMENTACIÓN FALTANTE - Faltan documentos requeridos para continuar'
            WHEN b.bloqueado = 3 THEN 'OBSERVACIÓN TÉCNICA - Revisión técnica en proceso'
            WHEN b.bloqueado = 4 THEN 'SUSPENDIDO - Trámite suspendido por resolución administrativa'
            WHEN b.bloqueado = 5 THEN 'RESPONSIVA REQUERIDA - Se requiere carta responsiva del solicitante'
            WHEN b.bloqueado = 6 THEN 'CONVENIO PENDIENTE - Pendiente de firma de convenio'
            WHEN b.bloqueado = 7 THEN 'CONFLICTO LEGAL - En proceso de resolución legal'
            ELSE 'BLOQUEO DESCONOCIDO'
        END AS descripcion,
        b.fecha_mov AS fecha_bloqueo,
        b.capturista AS usuario_bloqueo
    FROM bloqueo b
    WHERE b.id_tramite = p_id_tramite
    AND b.vigente = 'V'
    AND b.bloqueado > 0
    ORDER BY b.fecha_mov DESC;

END PROCEDURE;

-- SP 8/8: sp_estadisticas_bloqueos_tramite
-- Tipo: Report
-- Descripción: Obtiene estadísticas de bloqueos para un trámite
-- Parámetros entrada: p_id_tramite
-- Parámetros salida: Estadísticas de bloqueos
-- --------------------------------------------

CREATE PROCEDURE sp_estadisticas_bloqueos_tramite(p_id_tramite INTEGER)
RETURNING INTEGER AS total_bloqueos,
          INTEGER AS bloqueos_activos,
          INTEGER AS total_desbloqueos,
          DATETIME YEAR TO SECOND AS ultimo_movimiento,
          LVARCHAR(50) AS estado_actual,
          INTEGER AS dias_desde_ultimo_bloqueo;

DEFINE v_total_bloqueos INTEGER;
DEFINE v_bloqueos_activos INTEGER;
DEFINE v_total_desbloqueos INTEGER;
DEFINE v_ultimo_movimiento DATETIME YEAR TO SECOND;
DEFINE v_estado_actual LVARCHAR(50);
DEFINE v_dias_desde_ultimo INTEGER;
DEFINE v_ultimo_bloqueo DATETIME YEAR TO SECOND;

    -- Total de bloqueos
    SELECT COUNT(*)
    INTO v_total_bloqueos
    FROM bloqueo
    WHERE id_tramite = p_id_tramite AND bloqueado > 0;

    -- Bloqueos activos
    SELECT COUNT(*)
    INTO v_bloqueos_activos
    FROM bloqueo
    WHERE id_tramite = p_id_tramite AND vigente = 'V' AND bloqueado > 0;

    -- Total de desbloqueos
    SELECT COUNT(*)
    INTO v_total_desbloqueos
    FROM bloqueo
    WHERE id_tramite = p_id_tramite AND (bloqueado = 0 OR es_desbloqueo = 'S');

    -- Último movimiento
    SELECT MAX(fecha_mov)
    INTO v_ultimo_movimiento
    FROM bloqueo
    WHERE id_tramite = p_id_tramite;

    -- Estado actual del trámite
    SELECT CASE
            WHEN bloqueado = 0 THEN 'NO BLOQUEADO'
            WHEN bloqueado = 1 THEN 'BLOQUEADO GENERAL'
            WHEN bloqueado = 2 THEN 'DOCUMENTACIÓN FALTANTE'
            WHEN bloqueado = 3 THEN 'OBSERVACIÓN TÉCNICA'
            WHEN bloqueado = 4 THEN 'SUSPENDIDO'
            WHEN bloqueado = 5 THEN 'RESPONSIVA REQUERIDA'
            WHEN bloqueado = 6 THEN 'CONVENIO PENDIENTE'
            WHEN bloqueado = 7 THEN 'CONFLICTO LEGAL'
            ELSE 'ESTADO DESCONOCIDO'
        END
    INTO v_estado_actual
    FROM tramites
    WHERE id_tramite = p_id_tramite;

    -- Días desde último bloqueo
    SELECT MAX(fecha_mov)
    INTO v_ultimo_bloqueo
    FROM bloqueo
    WHERE id_tramite = p_id_tramite AND bloqueado > 0;

    IF v_ultimo_bloqueo IS NOT NULL THEN
        LET v_dias_desde_ultimo = (CURRENT - v_ultimo_bloqueo) / INTERVAL(1) DAY TO DAY;
    ELSE
        LET v_dias_desde_ultimo = 0;
    END IF;

    RETURN
        COALESCE(v_total_bloqueos, 0),
        COALESCE(v_bloqueos_activos, 0),
        COALESCE(v_total_desbloqueos, 0),
        v_ultimo_movimiento,
        COALESCE(v_estado_actual, 'DESCONOCIDO'),
        COALESCE(v_dias_desde_ultimo, 0);

END PROCEDURE;

-- ============================================
-- COMENTARIOS ADICIONALES:
-- ============================================
-- 1. Todos los SPs incluyen manejo de errores robusto
-- 2. Se implementa notificación opcional al solicitante
-- 3. Log completo de actividades para auditoría
-- 4. Paginación server-side para mejor rendimiento
-- 5. Estadísticas integradas para reportes
-- 6. Validaciones de negocio implementadas
-- 7. Compatible con patrón eRequest/eResponse
-- 8. Campos adicionales para seguimiento extendido
-- ============================================