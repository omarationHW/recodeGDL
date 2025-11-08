-- ============================================
-- STORED PROCEDURES FOR INFORMIX COMPATIBILITY
-- Component: gestionHologramasfrm.vue
-- Base: padron_licencias
-- Description: Procedures for hologram management
-- ============================================

-- 1. sp_hologramas_list - List holograms with filters
DROP PROCEDURE IF EXISTS sp_hologramas_list;

CREATE PROCEDURE sp_hologramas_list(
    p_serie VARCHAR(50),
    p_estado VARCHAR(20),
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_limite INTEGER,
    p_offset INTEGER
)
RETURNING
    INTEGER AS id,
    VARCHAR(50) AS serie,
    VARCHAR(100) AS codigo_qr,
    VARCHAR(20) AS estado,
    INTEGER AS numero_licencia,
    VARCHAR(255) AS propietario,
    VARCHAR(255) AS actividad,
    DATE AS fecha_asignacion,
    DATE AS fecha_vencimiento,
    VARCHAR(100) AS usuario_asigno,
    VARCHAR(500) AS observaciones,
    INTEGER AS total_registros;

    DEFINE v_id INTEGER;
    DEFINE v_serie VARCHAR(50);
    DEFINE v_codigo_qr VARCHAR(100);
    DEFINE v_estado VARCHAR(20);
    DEFINE v_numero_licencia INTEGER;
    DEFINE v_propietario VARCHAR(255);
    DEFINE v_actividad VARCHAR(255);
    DEFINE v_fecha_asignacion DATE;
    DEFINE v_fecha_vencimiento DATE;
    DEFINE v_usuario_asigno VARCHAR(100);
    DEFINE v_observaciones VARCHAR(500);
    DEFINE v_total INTEGER;

    -- Count total records
    SELECT COUNT(*)
    INTO v_total
    FROM hologramas h
    LEFT JOIN licencias l ON h.numero_licencia = l.licencia
    WHERE (p_serie IS NULL OR h.serie LIKE '%' || p_serie || '%')
      AND (p_estado IS NULL OR h.estado = p_estado)
      AND (p_fecha_desde IS NULL OR h.fecha_asignacion >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR h.fecha_asignacion <= p_fecha_hasta);

    -- Return paginated results
    FOREACH SELECT
        h.id,
        h.serie,
        NVL(h.codigo_qr, ''),
        NVL(h.estado, 'DISPONIBLE'),
        h.numero_licencia,
        NVL(l.propietario, ''),
        NVL(l.actividad, ''),
        h.fecha_asignacion,
        h.fecha_vencimiento,
        NVL(h.usuario_asigno, ''),
        NVL(h.observaciones, '')
    INTO
        v_id, v_serie, v_codigo_qr, v_estado, v_numero_licencia,
        v_propietario, v_actividad, v_fecha_asignacion, v_fecha_vencimiento,
        v_usuario_asigno, v_observaciones
    FROM hologramas h
    LEFT JOIN licencias l ON h.numero_licencia = l.licencia
    WHERE (p_serie IS NULL OR h.serie LIKE '%' || p_serie || '%')
      AND (p_estado IS NULL OR h.estado = p_estado)
      AND (p_fecha_desde IS NULL OR h.fecha_asignacion >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR h.fecha_asignacion <= p_fecha_hasta)
    ORDER BY h.fecha_asignacion DESC, h.serie
    SKIP p_offset
    FIRST p_limite

        RETURN v_id, v_serie, v_codigo_qr, v_estado, v_numero_licencia,
               v_propietario, v_actividad, v_fecha_asignacion, v_fecha_vencimiento,
               v_usuario_asigno, v_observaciones, v_total
        WITH RESUME;

    END FOREACH;

END PROCEDURE;

-- ============================================

-- 2. sp_hologramas_estadisticas - Get hologram statistics
DROP PROCEDURE IF EXISTS sp_hologramas_estadisticas;

CREATE PROCEDURE sp_hologramas_estadisticas()
RETURNING
    INTEGER AS total_hologramas,
    INTEGER AS disponibles,
    INTEGER AS asignados,
    INTEGER AS vencidos,
    INTEGER AS bloqueados,
    INTEGER AS duplicados;

    DEFINE v_total INTEGER;
    DEFINE v_disponibles INTEGER;
    DEFINE v_asignados INTEGER;
    DEFINE v_vencidos INTEGER;
    DEFINE v_bloqueados INTEGER;
    DEFINE v_duplicados INTEGER;

    -- Total holograms
    SELECT COUNT(*) INTO v_total FROM hologramas;

    -- Available holograms
    SELECT COUNT(*) INTO v_disponibles
    FROM hologramas
    WHERE estado = 'DISPONIBLE';

    -- Assigned holograms
    SELECT COUNT(*) INTO v_asignados
    FROM hologramas
    WHERE estado = 'ASIGNADO';

    -- Expired holograms
    SELECT COUNT(*) INTO v_vencidos
    FROM hologramas
    WHERE estado = 'VENCIDO' OR fecha_vencimiento < TODAY;

    -- Blocked holograms
    SELECT COUNT(*) INTO v_bloqueados
    FROM hologramas
    WHERE estado = 'BLOQUEADO';

    -- Duplicate series
    SELECT COUNT(*) INTO v_duplicados
    FROM (
        SELECT serie
        FROM hologramas
        GROUP BY serie
        HAVING COUNT(*) > 1
    ) tmp;

    RETURN v_total, v_disponibles, v_asignados, v_vencidos, v_bloqueados, v_duplicados
    WITH RESUME;

END PROCEDURE;

-- ============================================

-- 3. sp_hologramas_verificar - Verify hologram by series or QR code
DROP PROCEDURE IF EXISTS sp_hologramas_verificar;

CREATE PROCEDURE sp_hologramas_verificar(
    p_serie VARCHAR(50),
    p_codigo_qr VARCHAR(100)
)
RETURNING
    INTEGER AS id,
    VARCHAR(50) AS serie,
    VARCHAR(100) AS codigo_qr,
    VARCHAR(20) AS estado,
    INTEGER AS numero_licencia,
    VARCHAR(255) AS propietario,
    VARCHAR(255) AS actividad,
    DATE AS fecha_asignacion,
    DATE AS fecha_vencimiento,
    CHAR(1) AS es_valido,
    VARCHAR(255) AS mensaje_verificacion;

    DEFINE v_id INTEGER;
    DEFINE v_serie VARCHAR(50);
    DEFINE v_codigo_qr VARCHAR(100);
    DEFINE v_estado VARCHAR(20);
    DEFINE v_numero_licencia INTEGER;
    DEFINE v_propietario VARCHAR(255);
    DEFINE v_actividad VARCHAR(255);
    DEFINE v_fecha_asignacion DATE;
    DEFINE v_fecha_vencimiento DATE;
    DEFINE v_es_valido CHAR(1);
    DEFINE v_mensaje VARCHAR(255);

    -- Search by series or QR code
    SELECT
        h.id,
        h.serie,
        NVL(h.codigo_qr, ''),
        NVL(h.estado, 'DISPONIBLE'),
        h.numero_licencia,
        NVL(l.propietario, ''),
        NVL(l.actividad, ''),
        h.fecha_asignacion,
        h.fecha_vencimiento
    INTO
        v_id, v_serie, v_codigo_qr, v_estado, v_numero_licencia,
        v_propietario, v_actividad, v_fecha_asignacion, v_fecha_vencimiento
    FROM hologramas h
    LEFT JOIN licencias l ON h.numero_licencia = l.licencia
    WHERE (p_serie IS NOT NULL AND h.serie = p_serie)
       OR (p_codigo_qr IS NOT NULL AND h.codigo_qr = p_codigo_qr);

    -- Validate hologram
    IF SQLCA.SQLCODE != 0 THEN
        LET v_es_valido = 'N';
        LET v_mensaje = 'Holograma no encontrado';
    ELSE
        IF v_estado = 'BLOQUEADO' THEN
            LET v_es_valido = 'N';
            LET v_mensaje = 'Holograma bloqueado';
        ELIF v_estado = 'VENCIDO' OR v_fecha_vencimiento < TODAY THEN
            LET v_es_valido = 'N';
            LET v_mensaje = 'Holograma vencido';
        ELIF v_estado = 'ASIGNADO' THEN
            LET v_es_valido = 'S';
            LET v_mensaje = 'Holograma válido y asignado';
        ELSE
            LET v_es_valido = 'S';
            LET v_mensaje = 'Holograma válido';
        END IF;
    END IF;

    RETURN v_id, v_serie, v_codigo_qr, v_estado, v_numero_licencia,
           v_propietario, v_actividad, v_fecha_asignacion, v_fecha_vencimiento,
           v_es_valido, v_mensaje
    WITH RESUME;

END PROCEDURE;

-- ============================================

-- 4. sp_hologramas_generar_qr - Generate QR code for hologram
DROP PROCEDURE IF EXISTS sp_hologramas_generar_qr;

CREATE PROCEDURE sp_hologramas_generar_qr(p_holograma_id INTEGER)
RETURNING
    VARCHAR(100) AS codigo_qr,
    VARCHAR(50) AS status,
    VARCHAR(255) AS mensaje;

    DEFINE v_serie VARCHAR(50);
    DEFINE v_codigo_qr VARCHAR(100);
    DEFINE v_exists INTEGER;

    -- Check if hologram exists
    SELECT COUNT(*)
    INTO v_exists
    FROM hologramas
    WHERE id = p_holograma_id;

    IF v_exists = 0 THEN
        RETURN '', 'ERROR', 'Holograma no encontrado' WITH RESUME;
    END IF;

    -- Get series
    SELECT serie
    INTO v_serie
    FROM hologramas
    WHERE id = p_holograma_id;

    -- Generate QR code (simple format: HOLO-SERIE-TIMESTAMP)
    LET v_codigo_qr = 'HOLO-' || v_serie || '-' || YEAR(TODAY) || MONTH(TODAY) || DAY(TODAY);

    -- Update hologram with QR code
    UPDATE hologramas
    SET codigo_qr = v_codigo_qr,
        fecha_modificacion = TODAY
    WHERE id = p_holograma_id;

    IF SQLCA.SQLCODE = 0 THEN
        RETURN v_codigo_qr, 'SUCCESS', 'Código QR generado exitosamente' WITH RESUME;
    ELSE
        RETURN '', 'ERROR', 'Error al generar código QR' WITH RESUME;
    END IF;

END PROCEDURE;

-- ============================================

-- 5. sp_hologramas_delete - Delete hologram (logical deletion)
DROP PROCEDURE IF EXISTS sp_hologramas_delete;

CREATE PROCEDURE sp_hologramas_delete(p_holograma_id INTEGER)
RETURNING
    VARCHAR(50) AS status,
    VARCHAR(255) AS mensaje;

    DEFINE v_exists INTEGER;
    DEFINE v_estado VARCHAR(20);

    -- Check if hologram exists
    SELECT COUNT(*), NVL(MAX(estado), '')
    INTO v_exists, v_estado
    FROM hologramas
    WHERE id = p_holograma_id;

    IF v_exists = 0 THEN
        RETURN 'ERROR', 'Holograma no encontrado' WITH RESUME;
    END IF;

    -- Check if hologram can be deleted
    IF v_estado = 'ASIGNADO' THEN
        RETURN 'ERROR', 'No se puede eliminar un holograma asignado' WITH RESUME;
    END IF;

    -- Mark as deleted (logical deletion)
    UPDATE hologramas
    SET estado = 'ELIMINADO',
        fecha_modificacion = TODAY
    WHERE id = p_holograma_id;

    IF SQLCA.SQLCODE = 0 THEN
        RETURN 'SUCCESS', 'Holograma eliminado exitosamente' WITH RESUME;
    ELSE
        RETURN 'ERROR', 'Error al eliminar el holograma' WITH RESUME;
    END IF;

END PROCEDURE;

-- ============================================

-- 6. sp_hologramas_asignar - Assign hologram to license
DROP PROCEDURE IF EXISTS sp_hologramas_asignar;

CREATE PROCEDURE sp_hologramas_asignar(
    p_holograma_id INTEGER,
    p_numero_licencia INTEGER,
    p_usuario VARCHAR(100),
    p_observaciones VARCHAR(500)
)
RETURNING
    VARCHAR(50) AS status,
    VARCHAR(255) AS mensaje;

    DEFINE v_holo_exists INTEGER;
    DEFINE v_lic_exists INTEGER;
    DEFINE v_estado VARCHAR(20);
    DEFINE v_fecha_vencimiento DATE;

    -- Check if hologram exists and is available
    SELECT COUNT(*), NVL(MAX(estado), '')
    INTO v_holo_exists, v_estado
    FROM hologramas
    WHERE id = p_holograma_id;

    IF v_holo_exists = 0 THEN
        RETURN 'ERROR', 'Holograma no encontrado' WITH RESUME;
    END IF;

    IF v_estado != 'DISPONIBLE' THEN
        RETURN 'ERROR', 'Holograma no disponible para asignación' WITH RESUME;
    END IF;

    -- Check if license exists
    SELECT COUNT(*)
    INTO v_lic_exists
    FROM licencias
    WHERE licencia = p_numero_licencia;

    IF v_lic_exists = 0 THEN
        RETURN 'ERROR', 'Licencia no encontrada' WITH RESUME;
    END IF;

    -- Calculate expiration date (1 year from today)
    LET v_fecha_vencimiento = TODAY + 365;

    -- Assign hologram to license
    UPDATE hologramas
    SET numero_licencia = p_numero_licencia,
        estado = 'ASIGNADO',
        fecha_asignacion = TODAY,
        fecha_vencimiento = v_fecha_vencimiento,
        usuario_asigno = p_usuario,
        observaciones = p_observaciones,
        fecha_modificacion = TODAY
    WHERE id = p_holograma_id;

    IF SQLCA.SQLCODE = 0 THEN
        RETURN 'SUCCESS', 'Holograma asignado exitosamente' WITH RESUME;
    ELSE
        RETURN 'ERROR', 'Error al asignar el holograma' WITH RESUME;
    END IF;

END PROCEDURE;