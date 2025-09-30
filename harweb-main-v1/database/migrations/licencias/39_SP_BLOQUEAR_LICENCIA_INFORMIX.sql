-- ============================================
-- STORED PROCEDURES COMPLETOS - INFORMIX
-- Formulario: BLOQUEARLICENCIAFRM
-- Archivo: 39_SP_BLOQUEAR_LICENCIA_INFORMIX.sql
-- Sistema de Bloqueo/Desbloqueo de Licencias Comerciales
-- Fecha: 2025-09-30
-- Total SPs: 8
-- ============================================

-- SP 1/8: sp_bloquear_licencia
-- Tipo: CRUD
-- Descripción: Bloquea una licencia con validaciones completas y registro de auditoria
-- Parámetros entrada: p_id_licencia (INTEGER), p_tipo_bloqueo (INTEGER), p_motivo (LVARCHAR), p_usuario (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE sp_bloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo LVARCHAR(500),
    p_usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_licencia_existe INTEGER;
DEFINE v_bloqueado_actual INTEGER;
DEFINE v_tipo_valido INTEGER;
DEFINE v_fecha_expedicion DATE;
DEFINE v_vigencia_hasta DATE;
DEFINE v_calle LVARCHAR(255);
DEFINE v_cvecalle INTEGER;
DEFINE v_noext LVARCHAR(50);
DEFINE v_noint LVARCHAR(50);
DEFINE v_letext LVARCHAR(50);
DEFINE v_letint LVARCHAR(50);
DEFINE v_bloqueos INTEGER;
DEFINE v_id_bloqueo INTEGER;

    -- Validar que la licencia existe
    SELECT COUNT(*), bloqueado, fecha_expedicion, vigencia_hasta
    INTO v_licencia_existe, v_bloqueado_actual, v_fecha_expedicion, v_vigencia_hasta
    FROM licencias
    WHERE id_licencia = p_id_licencia;

    IF v_licencia_existe = 0 THEN
        RETURN 0, 'Error: La licencia no existe en el sistema';
    END IF;

    -- Validar que la licencia no esté ya bloqueada
    IF v_bloqueado_actual > 0 THEN
        RETURN 0, 'Error: La licencia ya está bloqueada con tipo ' || v_bloqueado_actual;
    END IF;

    -- Validar que el tipo de bloqueo existe
    SELECT COUNT(*) INTO v_tipo_valido
    FROM tipos_bloqueo
    WHERE id_tipo_bloqueo = p_tipo_bloqueo AND activo = 1;

    IF v_tipo_valido = 0 THEN
        RETURN 0, 'Error: Tipo de bloqueo no válido o inactivo';
    END IF;

    -- Validar que la licencia esté vigente (opcional)
    IF v_vigencia_hasta < TODAY THEN
        RETURN 0, 'Advertencia: La licencia ya está vencida desde ' || v_vigencia_hasta;
    END IF;

    -- Actualizar la licencia
    UPDATE licencias
    SET bloqueado = p_tipo_bloqueo,
        fecha_actualizacion = TODAY
    WHERE id_licencia = p_id_licencia;

    -- Cancelar bloqueos vigentes del mismo tipo (si existen)
    UPDATE bloqueo
    SET vigente = 'C',
        fecha_cancelacion = TODAY
    WHERE id_licencia = p_id_licencia
      AND vigente = 'V'
      AND bloqueado = p_tipo_bloqueo;

    -- Insertar el nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente, motivo_legal)
    VALUES (p_tipo_bloqueo, p_id_licencia, p_motivo, p_usuario, TODAY, 'V',
            CASE p_tipo_bloqueo
                WHEN 1 THEN 'INFRACCION_NORMATIVA'
                WHEN 2 THEN 'ADEUDO_FISCAL'
                WHEN 3 THEN 'PROBLEMA_LEGAL'
                WHEN 4 THEN 'SUSPENSION_ADMINISTRATIVA'
                WHEN 5 THEN 'RESPONSIVA'
                ELSE 'OTRO'
            END);

    -- Obtener el ID del bloqueo insertado
    SELECT MAX(id_bloqueo) INTO v_id_bloqueo
    FROM bloqueo
    WHERE id_licencia = p_id_licencia AND capturista = p_usuario;

    -- Si el tipo de bloqueo no es 'responsiva', bloquear domicilio si no hay otro bloqueo activo
    IF p_tipo_bloqueo <> 5 THEN
        -- Obtener datos del domicilio
        SELECT ubicacion, cvecalle, numext_ubic, numint_ubic, letraext_ubic, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_noint, v_letext, v_letint
        FROM public
        WHERE id_licencia = p_id_licencia;

        -- Contar bloqueos activos (debe ser 1 después de la inserción)
        SELECT COUNT(*) INTO v_bloqueos
        FROM bloqueo
        WHERE id_licencia = p_id_licencia
          AND vigente = 'V'
          AND bloqueado > 0;

        -- Si es el primer bloqueo, bloquear domicilio
        IF v_bloqueos = 1 THEN
            INSERT INTO bloqueo_dom (calle, cvecalle, num_ext, let_ext, num_int, let_int,
                                   observacion, vig, fecha, capturista, id_bloqueo_origen)
            VALUES (v_calle, v_cvecalle, v_noext, v_letext, v_noint, v_letint,
                   p_motivo, 'V', TODAY, p_usuario, v_id_bloqueo);
        END IF;
    END IF;

    -- Insertar en log de auditoria
    INSERT INTO auditoria_bloqueos (accion, id_licencia, tipo_bloqueo_anterior, tipo_bloqueo_nuevo,
                                  motivo, usuario, fecha_accion, direccion_ip)
    VALUES ('BLOQUEO', p_id_licencia, v_bloqueado_actual, p_tipo_bloqueo,
           p_motivo, p_usuario, TODAY, '0.0.0.0');

    RETURN 1, 'Licencia bloqueada exitosamente con ID de movimiento: ' || v_id_bloqueo;

END PROCEDURE;

-- SP 2/8: sp_desbloquear_licencia
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia con validaciones completas y registro de auditoria
-- Parámetros entrada: p_id_licencia (INTEGER), p_tipo_bloqueo (INTEGER), p_motivo (LVARCHAR), p_usuario (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE sp_desbloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo LVARCHAR(500),
    p_usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_licencia_existe INTEGER;
DEFINE v_bloqueado_actual INTEGER;
DEFINE v_calle LVARCHAR(255);
DEFINE v_cvecalle INTEGER;
DEFINE v_noext LVARCHAR(50);
DEFINE v_noint LVARCHAR(50);
DEFINE v_letext LVARCHAR(50);
DEFINE v_letint LVARCHAR(50);
DEFINE v_bloqueos INTEGER;
DEFINE v_id_bloqueo INTEGER;
DEFINE v_dias_bloqueado INTEGER;

    -- Validar que la licencia existe y está bloqueada
    SELECT COUNT(*), bloqueado INTO v_licencia_existe, v_bloqueado_actual
    FROM licencias
    WHERE id_licencia = p_id_licencia;

    IF v_licencia_existe = 0 THEN
        RETURN 0, 'Error: La licencia no existe en el sistema';
    END IF;

    IF v_bloqueado_actual = 0 THEN
        RETURN 0, 'Error: La licencia no está bloqueada';
    END IF;

    IF v_bloqueado_actual <> p_tipo_bloqueo THEN
        RETURN 0, 'Error: La licencia está bloqueada con tipo ' || v_bloqueado_actual || ', no con tipo ' || p_tipo_bloqueo;
    END IF;

    -- Calcular días que estuvo bloqueada
    SELECT (TODAY - MAX(fecha_mov)) INTO v_dias_bloqueado
    FROM bloqueo
    WHERE id_licencia = p_id_licencia
      AND vigente = 'V'
      AND bloqueado = p_tipo_bloqueo;

    -- Actualizar la licencia
    UPDATE licencias
    SET bloqueado = 0,
        fecha_actualizacion = TODAY
    WHERE id_licencia = p_id_licencia;

    -- Cancelar bloqueos vigentes del tipo especificado
    UPDATE bloqueo
    SET vigente = 'C',
        fecha_cancelacion = TODAY
    WHERE id_licencia = p_id_licencia
      AND vigente = 'V'
      AND bloqueado = p_tipo_bloqueo;

    -- Insertar el desbloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente, motivo_legal)
    VALUES (0, p_id_licencia, p_motivo, p_usuario, TODAY, 'V', 'DESBLOQUEO');

    -- Obtener el ID del desbloqueo insertado
    SELECT MAX(id_bloqueo) INTO v_id_bloqueo
    FROM bloqueo
    WHERE id_licencia = p_id_licencia AND capturista = p_usuario;

    -- Verificar si quedan más bloqueos activos
    SELECT COUNT(*) INTO v_bloqueos
    FROM bloqueo
    WHERE id_licencia = p_id_licencia
      AND vigente = 'V'
      AND bloqueado > 0;

    -- Si no hay más bloqueos activos, desbloquear domicilio
    IF v_bloqueos = 0 THEN
        -- Obtener datos del domicilio
        SELECT ubicacion, cvecalle, numext_ubic, numint_ubic, letraext_ubic, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_noint, v_letext, v_letint
        FROM public
        WHERE id_licencia = p_id_licencia;

        -- Cancelar bloqueos de domicilio
        UPDATE bloqueo_dom
        SET vig = 'C',
            fecha_desbloqueo = TODAY,
            usuario_desbloqueo = p_usuario
        WHERE calle = v_calle
          AND cvecalle = v_cvecalle
          AND num_ext = v_noext
          AND let_ext = v_letext
          AND num_int = v_noint
          AND let_int = v_letint
          AND vig = 'V';
    END IF;

    -- Insertar en log de auditoria
    INSERT INTO auditoria_bloqueos (accion, id_licencia, tipo_bloqueo_anterior, tipo_bloqueo_nuevo,
                                  motivo, usuario, fecha_accion, direccion_ip, dias_bloqueado)
    VALUES ('DESBLOQUEO', p_id_licencia, v_bloqueado_actual, 0,
           p_motivo, p_usuario, TODAY, '0.0.0.0', v_dias_bloqueado);

    RETURN 1, 'Licencia desbloqueada exitosamente. Estuvo bloqueada ' || v_dias_bloqueado || ' días. ID: ' || v_id_bloqueo;

END PROCEDURE;

-- SP 3/8: buscar_licencia
-- Tipo: Catalog
-- Descripción: Busca una licencia por su número con información completa
-- Parámetros entrada: numero_licencia (INTEGER)
-- Parámetros salida: Datos completos de la licencia
-- --------------------------------------------

CREATE PROCEDURE buscar_licencia(numero_licencia INTEGER)
RETURNING INTEGER AS id_licencia,
          INTEGER AS licencia,
          LVARCHAR(255) AS giro,
          DATE AS fecha_expedicion,
          DATE AS vigencia_hasta,
          LVARCHAR(255) AS nombre_propietario,
          LVARCHAR(255) AS ubicacion,
          INTEGER AS bloqueado,
          LVARCHAR(100) AS estado_licencia,
          INTEGER AS dias_vigencia,
          LVARCHAR(50) AS telefono,
          LVARCHAR(100) AS email;

DEFINE v_dias INTEGER;
DEFINE v_estado LVARCHAR(100);

    -- Calcular días de vigencia y estado
    SELECT (vigencia_hasta - TODAY) INTO v_dias
    FROM licencias
    WHERE licencia = numero_licencia;

    IF v_dias > 30 THEN
        LET v_estado = 'VIGENTE';
    ELIF v_dias > 0 THEN
        LET v_estado = 'POR_VENCER';
    ELSE
        LET v_estado = 'VENCIDA';
    END IF;

    RETURN
        l.id_licencia,
        l.licencia,
        g.descripcion AS giro,
        l.fecha_expedicion,
        l.vigencia_hasta,
        TRIM(p.nombre) || ' ' || TRIM(p.apellido_paterno) || ' ' || TRIM(p.apellido_materno) AS nombre_propietario,
        pu.ubicacion,
        l.bloqueado,
        v_estado AS estado_licencia,
        v_dias AS dias_vigencia,
        p.telefono,
        p.email
    FROM licencias l
    LEFT JOIN giros g ON l.id_giro = g.id_giro
    LEFT JOIN public pu ON l.id_licencia = pu.id_licencia
    LEFT JOIN propietarios p ON l.id_propietario = p.id_propietario
    WHERE l.licencia = numero_licencia;

END PROCEDURE;

-- SP 4/8: sp_tipobloqueo_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de bloqueo disponibles con información adicional
-- Parámetros entrada: Ninguno
-- Parámetros salida: id, descripcion, requiere_apelacion, multa_base
-- --------------------------------------------

CREATE PROCEDURE sp_tipobloqueo_list()
RETURNING INTEGER AS id,
          LVARCHAR(255) AS descripcion,
          CHAR(1) AS requiere_apelacion,
          DECIMAL(10,2) AS multa_base,
          INTEGER AS orden_gravedad;

    RETURN
        id_tipo_bloqueo AS id,
        descripcion,
        requiere_apelacion,
        multa_base,
        orden_gravedad
    FROM tipos_bloqueo
    WHERE activo = 1
    ORDER BY orden_gravedad, descripcion;

END PROCEDURE;

-- SP 5/8: sp_consultar_historial_licencia_paginado
-- Tipo: Catalog
-- Descripción: Consulta el historial de bloqueos con paginación server-side
-- Parámetros entrada: p_id_licencia (INTEGER), limit_records (INTEGER), offset_records (INTEGER)
-- Parámetros salida: Historial paginado con totales
-- --------------------------------------------

CREATE PROCEDURE sp_consultar_historial_licencia_paginado(
    p_id_licencia INTEGER,
    limit_records INTEGER,
    offset_records INTEGER
)
RETURNING INTEGER AS id_bloqueo,
          INTEGER AS bloqueado,
          DATE AS fecha_mov,
          LVARCHAR(50) AS capturista,
          LVARCHAR(500) AS observa,
          LVARCHAR(50) AS motivo_legal,
          DATE AS fecha_cancelacion,
          INTEGER AS total_registros,
          INTEGER AS numero_fila;

DEFINE v_total INTEGER;

    -- Obtener el total de registros
    SELECT COUNT(*) INTO v_total
    FROM bloqueo
    WHERE id_licencia = p_id_licencia;

    RETURN
        b.id_bloqueo,
        b.bloqueado,
        b.fecha_mov,
        b.capturista,
        b.observa,
        b.motivo_legal,
        b.fecha_cancelacion,
        v_total AS total_registros,
        ROW_NUMBER() OVER (ORDER BY b.fecha_mov DESC) AS numero_fila
    FROM bloqueo b
    WHERE b.id_licencia = p_id_licencia
    ORDER BY b.fecha_mov DESC
    SKIP offset_records
    FIRST limit_records;

END PROCEDURE;

-- SP 6/8: sp_consultar_historial_licencia
-- Tipo: Catalog
-- Descripción: Consulta completa del historial sin paginación (fallback)
-- Parámetros entrada: p_id_licencia (INTEGER)
-- Parámetros salida: Historial completo
-- --------------------------------------------

CREATE PROCEDURE sp_consultar_historial_licencia(p_id_licencia INTEGER)
RETURNING INTEGER AS id_bloqueo,
          INTEGER AS bloqueado,
          DATE AS fecha_mov,
          LVARCHAR(50) AS capturista,
          LVARCHAR(500) AS observa,
          LVARCHAR(50) AS motivo_legal,
          DATE AS fecha_cancelacion,
          CHAR(1) AS vigente;

    RETURN
        id_bloqueo,
        bloqueado,
        fecha_mov,
        capturista,
        observa,
        motivo_legal,
        fecha_cancelacion,
        vigente
    FROM bloqueo
    WHERE id_licencia = p_id_licencia
    ORDER BY fecha_mov DESC;

END PROCEDURE;

-- SP 7/8: sp_validar_bloqueo_licencia
-- Tipo: Validation
-- Descripción: Valida si una licencia puede ser bloqueada/desbloqueada
-- Parámetros entrada: p_id_licencia (INTEGER), p_accion (LVARCHAR), p_tipo_bloqueo (INTEGER)
-- Parámetros salida: puede_proceder (INTEGER), mensaje (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE sp_validar_bloqueo_licencia(
    p_id_licencia INTEGER,
    p_accion LVARCHAR(20),
    p_tipo_bloqueo INTEGER
)
RETURNING INTEGER AS puede_proceder,
          LVARCHAR(255) AS mensaje,
          INTEGER AS codigo_error;

DEFINE v_existe INTEGER;
DEFINE v_bloqueado INTEGER;
DEFINE v_vigencia DATE;
DEFINE v_tipo_valido INTEGER;
DEFINE v_bloqueos_activos INTEGER;

    -- Verificar existencia de la licencia
    SELECT COUNT(*), bloqueado, vigencia_hasta
    INTO v_existe, v_bloqueado, v_vigencia
    FROM licencias
    WHERE id_licencia = p_id_licencia;

    IF v_existe = 0 THEN
        RETURN 0, 'La licencia no existe', 404;
    END IF;

    -- Validaciones específicas por acción
    IF p_accion = 'BLOQUEAR' THEN
        IF v_bloqueado > 0 THEN
            RETURN 0, 'La licencia ya está bloqueada', 409;
        END IF;

        -- Verificar que el tipo de bloqueo existe
        SELECT COUNT(*) INTO v_tipo_valido
        FROM tipos_bloqueo
        WHERE id_tipo_bloqueo = p_tipo_bloqueo AND activo = 1;

        IF v_tipo_valido = 0 THEN
            RETURN 0, 'Tipo de bloqueo no válido', 400;
        END IF;

        IF v_vigencia < TODAY THEN
            RETURN 1, 'Advertencia: Licencia vencida', 200;
        END IF;

    ELIF p_accion = 'DESBLOQUEAR' THEN
        IF v_bloqueado = 0 THEN
            RETURN 0, 'La licencia no está bloqueada', 409;
        END IF;

        IF v_bloqueado <> p_tipo_bloqueo THEN
            RETURN 0, 'Tipo de bloqueo no coincide', 409;
        END IF;
    END IF;

    RETURN 1, 'Validación exitosa', 200;

END PROCEDURE;

-- SP 8/8: sp_estadisticas_bloqueos
-- Tipo: Report
-- Descripción: Obtiene estadísticas generales de bloqueos
-- Parámetros entrada: Ninguno
-- Parámetros salida: Estadísticas consolidadas
-- --------------------------------------------

CREATE PROCEDURE sp_estadisticas_bloqueos()
RETURNING INTEGER AS total_licencias,
          INTEGER AS licencias_bloqueadas,
          INTEGER AS licencias_activas,
          INTEGER AS bloqueos_mes_actual,
          INTEGER AS desbloqueos_mes_actual,
          LVARCHAR(100) AS tipo_bloqueo_mas_comun,
          DECIMAL(5,2) AS porcentaje_bloqueos;

DEFINE v_total INTEGER;
DEFINE v_bloqueadas INTEGER;
DEFINE v_activas INTEGER;
DEFINE v_bloqueos_mes INTEGER;
DEFINE v_desbloqueos_mes INTEGER;
DEFINE v_tipo_comun LVARCHAR(100);
DEFINE v_porcentaje DECIMAL(5,2);

    -- Total de licencias
    SELECT COUNT(*) INTO v_total FROM licencias;

    -- Licencias bloqueadas
    SELECT COUNT(*) INTO v_bloqueadas FROM licencias WHERE bloqueado > 0;

    -- Licencias activas
    LET v_activas = v_total - v_bloqueadas;

    -- Bloqueos del mes actual
    SELECT COUNT(*) INTO v_bloqueos_mes
    FROM bloqueo
    WHERE MONTH(fecha_mov) = MONTH(TODAY)
      AND YEAR(fecha_mov) = YEAR(TODAY)
      AND bloqueado > 0;

    -- Desbloqueos del mes actual
    SELECT COUNT(*) INTO v_desbloqueos_mes
    FROM bloqueo
    WHERE MONTH(fecha_mov) = MONTH(TODAY)
      AND YEAR(fecha_mov) = YEAR(TODAY)
      AND bloqueado = 0;

    -- Tipo de bloqueo más común
    SELECT tb.descripcion INTO v_tipo_comun
    FROM tipos_bloqueo tb
    JOIN (
        SELECT bloqueado, COUNT(*) as cantidad
        FROM bloqueo
        WHERE bloqueado > 0
        GROUP BY bloqueado
        ORDER BY cantidad DESC
        LIMIT 1
    ) b ON tb.id_tipo_bloqueo = b.bloqueado;

    -- Porcentaje de bloqueos
    IF v_total > 0 THEN
        LET v_porcentaje = (v_bloqueadas * 100.0) / v_total;
    ELSE
        LET v_porcentaje = 0;
    END IF;

    RETURN v_total, v_bloqueadas, v_activas, v_bloqueos_mes, v_desbloqueos_mes,
           v_tipo_comun, v_porcentaje;

END PROCEDURE;

-- ============================================
-- TABLAS AUXILIARES REQUERIDAS (SOLO CREAR SI NO EXISTEN)
-- ============================================

-- Tabla para tipos de bloqueo (si no existe)
CREATE TABLE IF NOT EXISTS tipos_bloqueo (
    id_tipo_bloqueo INTEGER NOT NULL PRIMARY KEY,
    descripcion LVARCHAR(255) NOT NULL,
    requiere_apelacion CHAR(1) DEFAULT 'N',
    multa_base DECIMAL(10,2) DEFAULT 0,
    orden_gravedad INTEGER DEFAULT 1,
    activo INTEGER DEFAULT 1
);

-- Tabla para auditoria de bloqueos (si no existe)
CREATE TABLE IF NOT EXISTS auditoria_bloqueos (
    id_auditoria SERIAL PRIMARY KEY,
    accion LVARCHAR(20) NOT NULL,
    id_licencia INTEGER NOT NULL,
    tipo_bloqueo_anterior INTEGER,
    tipo_bloqueo_nuevo INTEGER,
    motivo LVARCHAR(500),
    usuario LVARCHAR(50) NOT NULL,
    fecha_accion DATE NOT NULL,
    direccion_ip LVARCHAR(15),
    dias_bloqueado INTEGER
);

-- Datos iniciales para tipos_bloqueo (si la tabla está vacía)
INSERT INTO tipos_bloqueo (id_tipo_bloqueo, descripcion, requiere_apelacion, multa_base, orden_gravedad)
SELECT 1, 'INFRACCIÓN NORMATIVA', 'S', 1000.00, 1
WHERE NOT EXISTS (SELECT 1 FROM tipos_bloqueo WHERE id_tipo_bloqueo = 1);

INSERT INTO tipos_bloqueo (id_tipo_bloqueo, descripcion, requiere_apelacion, multa_base, orden_gravedad)
SELECT 2, 'ADEUDO FISCAL', 'N', 500.00, 2
WHERE NOT EXISTS (SELECT 1 FROM tipos_bloqueo WHERE id_tipo_bloqueo = 2);

INSERT INTO tipos_bloqueo (id_tipo_bloqueo, descripcion, requiere_apelacion, multa_base, orden_gravedad)
SELECT 3, 'PROBLEMA LEGAL', 'S', 2000.00, 3
WHERE NOT EXISTS (SELECT 1 FROM tipos_bloqueo WHERE id_tipo_bloqueo = 3);

INSERT INTO tipos_bloqueo (id_tipo_bloqueo, descripcion, requiere_apelacion, multa_base, orden_gravedad)
SELECT 4, 'SUSPENSIÓN ADMINISTRATIVA', 'S', 1500.00, 4
WHERE NOT EXISTS (SELECT 1 FROM tipos_bloqueo WHERE id_tipo_bloqueo = 4);

INSERT INTO tipos_bloqueo (id_tipo_bloqueo, descripcion, requiere_apelacion, multa_base, orden_gravedad)
SELECT 5, 'RESPONSIVA', 'N', 0.00, 5
WHERE NOT EXISTS (SELECT 1 FROM tipos_bloqueo WHERE id_tipo_bloqueo = 5);

-- ============================================
-- FIN DE ARCHIVO
-- ============================================