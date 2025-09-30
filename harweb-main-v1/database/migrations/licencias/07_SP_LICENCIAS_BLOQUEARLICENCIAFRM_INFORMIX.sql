-- ============================================
-- STORED PROCEDURES MIGRADOS - INFORMIX
-- Formulario: BLOQUEARLICENCIAFRM
-- Archivo: 07_SP_LICENCIAS_BLOQUEARLICENCIAFRM_INFORMIX.sql
-- Migración desde PostgreSQL a INFORMIX
-- Fecha: 2025-09-23
-- Total SPs: 5
-- ============================================

-- SP 1/1: sp_bloquear_licencia
-- Tipo: CRUD
-- Descripción: Bloquea una licencia, registra el movimiento y actualiza el estado de la licencia y domicilio si aplica.
-- Parámetros entrada: p_id_licencia (INTEGER), p_tipo_bloqueo (INTEGER), p_motivo (LVARCHAR), p_usuario (LVARCHAR)
-- Parámetros salida: Ninguno (VOID)
-- --------------------------------------------

CREATE PROCEDURE sp_bloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo LVARCHAR(500),
    p_usuario LVARCHAR(50)
);

DEFINE v_calle LVARCHAR(255);
DEFINE v_cvecalle INTEGER;
DEFINE v_noext LVARCHAR(50);
DEFINE v_noint LVARCHAR(50);
DEFINE v_letext LVARCHAR(50);
DEFINE v_letint LVARCHAR(50);
DEFINE v_bloqueos INTEGER;

    -- Actualiza la licencia
    UPDATE licencias
    SET bloqueado = p_tipo_bloqueo
    WHERE id_licencia = p_id_licencia;

    -- Cancela bloqueos vigentes del mismo tipo
    UPDATE bloqueo
    SET vigente = 'C'
    WHERE id_licencia = p_id_licencia
      AND vigente = 'V'
      AND bloqueado = p_tipo_bloqueo;

    -- Inserta el nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente)
    VALUES (p_tipo_bloqueo, p_id_licencia, p_motivo, p_usuario, TODAY, 'V');

    -- Si el tipo de bloqueo no es 'responsiva', bloquea domicilio si no hay otro bloqueo activo
    IF p_tipo_bloqueo <> 5 THEN
        -- Obtener datos del domicilio
        SELECT ubicacion, cvecalle, numext_ubic, numint_ubic, letraext_ubic, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_noint, v_letext, v_letint
        FROM public
        WHERE id_licencia = p_id_licencia;

        -- Contar bloqueos activos
        SELECT COUNT(*) INTO v_bloqueos
        FROM bloqueo
        WHERE id_licencia = p_id_licencia
          AND vigente = 'V'
          AND bloqueado > 0;

        -- Si es el primer bloqueo, bloquear domicilio
        IF v_bloqueos = 1 THEN
            INSERT INTO bloqueo_dom (calle, cvecalle, num_ext, let_ext, num_int, let_int, observacion, vig, fecha, capturista)
            VALUES (v_calle, v_cvecalle, v_noext, v_letext, v_noint, v_letint, p_motivo, 'V', TODAY, p_usuario);
        END IF;
    END IF;

END PROCEDURE;

-- SP 2/5: buscar_licencia
-- Tipo: Catalog
-- Descripción: Busca una licencia por su número y devuelve todos sus datos.
-- Parámetros entrada: numero_licencia (INTEGER)
-- Parámetros salida: id_licencia, giro, fecha_expedicion, vigencia_hasta, nombre_propietario, ubicacion, bloqueado
-- --------------------------------------------

CREATE PROCEDURE buscar_licencia(numero_licencia INTEGER)
RETURNING INTEGER AS id_licencia,
          LVARCHAR(255) AS giro,
          DATE AS fecha_expedicion,
          DATE AS vigencia_hasta,
          LVARCHAR(255) AS nombre_propietario,
          LVARCHAR(255) AS ubicacion,
          INTEGER AS bloqueado;

    RETURN
        l.id_licencia,
        g.descripcion AS giro,
        l.fecha_expedicion,
        l.vigencia_hasta,
        TRIM(p.nombre) || ' ' || TRIM(p.apellido_paterno) || ' ' || TRIM(p.apellido_materno) AS nombre_propietario,
        pu.ubicacion,
        l.bloqueado
    FROM licencias l
    LEFT JOIN giros g ON l.id_giro = g.id_giro
    LEFT JOIN public pu ON l.id_licencia = pu.id_licencia
    LEFT JOIN propietarios p ON l.id_propietario = p.id_propietario
    WHERE l.licencia = numero_licencia;

END PROCEDURE;

-- SP 3/5: sp_tipobloqueo_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de bloqueo disponibles.
-- Parámetros entrada: Ninguno
-- Parámetros salida: id, descripcion
-- --------------------------------------------

CREATE PROCEDURE sp_tipobloqueo_list()
RETURNING INTEGER AS id,
          LVARCHAR(255) AS descripcion;

    RETURN
        id_tipo_bloqueo AS id,
        descripcion
    FROM tipos_bloqueo
    WHERE activo = 1
    ORDER BY descripcion;

END PROCEDURE;

-- SP 4/5: sp_desbloquear_licencia
-- Tipo: CRUD
-- Descripción: Desbloquea una licencia, registra el movimiento y actualiza el estado.
-- Parámetros entrada: p_id_licencia (INTEGER), p_tipo_bloqueo (INTEGER), p_motivo (LVARCHAR), p_usuario (LVARCHAR)
-- Parámetros salida: success (BOOLEAN simulado con INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE sp_desbloquear_licencia(
    p_id_licencia INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo LVARCHAR(500),
    p_usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_bloqueado INTEGER;
DEFINE v_calle LVARCHAR(255);
DEFINE v_cvecalle INTEGER;
DEFINE v_noext LVARCHAR(50);
DEFINE v_noint LVARCHAR(50);
DEFINE v_letext LVARCHAR(50);
DEFINE v_letint LVARCHAR(50);
DEFINE v_bloqueos INTEGER;

    -- Verificar si la licencia existe y está bloqueada con ese tipo
    SELECT bloqueado INTO v_bloqueado
    FROM licencias
    WHERE id_licencia = p_id_licencia;

    IF v_bloqueado IS NULL THEN
        RETURN 0, 'No existe la licencia';
    END IF;

    IF v_bloqueado <> p_tipo_bloqueo THEN
        RETURN 0, 'La licencia no está bloqueada con ese tipo de bloqueo';
    END IF;

    -- Actualizar la licencia
    UPDATE licencias
    SET bloqueado = 0
    WHERE id_licencia = p_id_licencia;

    -- Cancelar bloqueos vigentes del tipo especificado
    UPDATE bloqueo
    SET vigente = 'C'
    WHERE id_licencia = p_id_licencia
      AND vigente = 'V'
      AND bloqueado = p_tipo_bloqueo;

    -- Insertar el desbloqueo
    INSERT INTO bloqueo (bloqueado, id_licencia, observa, capturista, fecha_mov, vigente)
    VALUES (0, p_id_licencia, p_motivo, p_usuario, TODAY, 'V');

    -- Si no hay más bloqueos activos, desbloquear domicilio
    SELECT COUNT(*) INTO v_bloqueos
    FROM bloqueo
    WHERE id_licencia = p_id_licencia
      AND vigente = 'V'
      AND bloqueado > 0;

    IF v_bloqueos = 0 THEN
        -- Obtener datos del domicilio
        SELECT ubicacion, cvecalle, numext_ubic, numint_ubic, letraext_ubic, letraint_ubic
        INTO v_calle, v_cvecalle, v_noext, v_noint, v_letext, v_letint
        FROM public
        WHERE id_licencia = p_id_licencia;

        -- Cancelar bloqueos de domicilio
        UPDATE bloqueo_dom
        SET vig = 'C'
        WHERE calle = v_calle
          AND cvecalle = v_cvecalle
          AND num_ext = v_noext
          AND let_ext = v_letext
          AND num_int = v_noint
          AND let_int = v_letint
          AND vig = 'V';
    END IF;

    RETURN 1, 'Licencia desbloqueada correctamente';

END PROCEDURE;

-- SP 5/5: sp_consultar_historial_licencia
-- Tipo: Catalog
-- Descripción: Consulta el historial de bloqueos de una licencia específica.
-- Parámetros entrada: p_id_licencia (INTEGER)
-- Parámetros salida: id_bloqueo, bloqueado, fecha_mov, capturista, observa
-- --------------------------------------------

CREATE PROCEDURE sp_consultar_historial_licencia(p_id_licencia INTEGER)
RETURNING INTEGER AS id_bloqueo,
          INTEGER AS bloqueado,
          DATE AS fecha_mov,
          LVARCHAR(50) AS capturista,
          LVARCHAR(500) AS observa;

    RETURN
        id_bloqueo,
        bloqueado,
        fecha_mov,
        capturista,
        observa
    FROM bloqueo
    WHERE id_licencia = p_id_licencia
    ORDER BY fecha_mov DESC;

END PROCEDURE;