-- ============================================
-- STORED PROCEDURES MIGRADOS - INFORMIX
-- Formulario: BLOQUEARTRAMITEFRM
-- Archivo: 08_SP_LICENCIAS_BLOQUEARTRAMITEFRM_INFORMIX.sql
-- Migración desde PostgreSQL a INFORMIX
-- Fecha: 2025-09-23
-- Total SPs: 6
-- ============================================

-- SP 1/3: get_tramite
-- Tipo: Catalog
-- Descripción: Obtiene los datos completos de un trámite por su id_tramite.
-- Parámetros entrada: p_id_tramite (INTEGER)
-- Parámetros salida: Todos los campos de la tabla tramites
-- --------------------------------------------

CREATE PROCEDURE get_tramite(p_id_tramite INTEGER)
RETURNING INTEGER AS id_tramite,
          INTEGER AS folio,
          LVARCHAR(50) AS tipo_tramite,
          INTEGER AS id_giro,
          FLOAT AS x,
          FLOAT AS y,
          SMALLINT AS zona,
          SMALLINT AS subzona,
          LVARCHAR(255) AS actividad,
          INTEGER AS cvecuenta,
          SMALLINT AS recaud,
          INTEGER AS licencia_ref,
          LVARCHAR(100) AS tramita_apoderado,
          LVARCHAR(100) AS propietario,
          LVARCHAR(100) AS primer_ap,
          LVARCHAR(100) AS segundo_ap,
          LVARCHAR(20) AS rfc,
          LVARCHAR(20) AS curp,
          LVARCHAR(255) AS domicilio,
          INTEGER AS numext_prop,
          LVARCHAR(50) AS numint_prop,
          LVARCHAR(100) AS colonia_prop,
          LVARCHAR(20) AS telefono_prop,
          LVARCHAR(100) AS email,
          INTEGER AS cvecalle,
          LVARCHAR(255) AS ubicacion,
          INTEGER AS numext_ubic,
          LVARCHAR(50) AS letraext_ubic,
          LVARCHAR(50) AS letraint_ubic,
          LVARCHAR(100) AS colonia_ubic,
          LVARCHAR(50) AS espubic,
          LVARCHAR(1000) AS documentos,
          FLOAT AS sup_construida,
          FLOAT AS sup_autorizada,
          SMALLINT AS num_cajones,
          SMALLINT AS num_empleados,
          SMALLINT AS aforo,
          DECIMAL(12,2) AS inversion,
          DECIMAL(10,2) AS costo,
          DATE AS fecha_consejo,
          INTEGER AS id_fabricante,
          LVARCHAR(255) AS texto_anuncio,
          FLOAT AS medidas1,
          FLOAT AS medidas2,
          FLOAT AS area_anuncio,
          SMALLINT AS num_caras,
          DECIMAL(10,2) AS calificacion,
          LVARCHAR(50) AS usr_califica,
          LVARCHAR(50) AS estatus,
          INTEGER AS id_licencia,
          INTEGER AS id_anuncio,
          DATE AS feccap,
          LVARCHAR(50) AS capturista,
          LVARCHAR(50) AS numint_ubic2,
          SMALLINT AS bloqueado,
          SMALLINT AS dictamen,
          LVARCHAR(1000) AS observaciones,
          LVARCHAR(100) AS rhorario,
          INTEGER AS cp;

    RETURN *
    FROM tramites
    WHERE id_tramite = p_id_tramite;

END PROCEDURE;

-- SP 2/3: get_giro_descripcion
-- Tipo: Catalog
-- Descripción: Obtiene la descripción del giro por id_giro.
-- Parámetros entrada: p_id_giro (INTEGER)
-- Parámetros salida: id_giro, descripcion
-- --------------------------------------------

CREATE PROCEDURE get_giro_descripcion(p_id_giro INTEGER)
RETURNING INTEGER AS id_giro,
          LVARCHAR(255) AS descripcion;

    RETURN id_giro, descripcion
    FROM c_giros
    WHERE id_giro = p_id_giro;

END PROCEDURE;

-- SP 3/3: desbloquear_tramite
-- Tipo: CRUD
-- Descripción: Desbloquea un trámite, cancela el último bloqueo vigente y registra el desbloqueo.
-- Parámetros entrada: p_id_tramite (INTEGER), p_observa (LVARCHAR), p_capturista (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE desbloquear_tramite(
    p_id_tramite INTEGER,
    p_observa LVARCHAR(500),
    p_capturista LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_count INTEGER;

    BEGIN
        -- Actualizar campo bloqueado en tramites
        UPDATE tramites
        SET bloqueado = 0
        WHERE id_tramite = p_id_tramite;

        -- Cancelar último bloqueo vigente
        UPDATE bloqueo
        SET vigente = 'C'
        WHERE id_tramite = p_id_tramite AND vigente = 'V';

        -- Insertar nuevo desbloqueo
        INSERT INTO bloqueo (bloqueado, id_tramite, observa, capturista, fecha_mov, vigente)
        VALUES (0, p_id_tramite, p_observa, p_capturista, TODAY, 'V');

        RETURN 1, 'Trámite desbloqueado correctamente';

    END

    ON EXCEPTION
        RETURN 0, 'Error al desbloquear trámite: ' || SQLCODE;
    END EXCEPTION;

END PROCEDURE;

-- SP 4/6: sp_buscar_tramite
-- Tipo: Catalog
-- Descripción: Busca un trámite por número y devuelve información completa.
-- Parámetros entrada: p_numero_tramite (INTEGER)
-- Parámetros salida: Datos del trámite con información adicional
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
          INTEGER AS bloqueado;

    RETURN
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        g.descripcion AS giro,
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.ubicacion,
        t.numext_ubic,
        t.letraext_ubic,
        t.numint_ubic,
        t.letraint_ubic,
        t.actividad,
        t.bloqueado
    FROM tramites t
    LEFT JOIN c_giros g ON t.id_giro = g.id_giro
    WHERE t.id_tramite = p_numero_tramite;

END PROCEDURE;

-- SP 5/6: sp_bloquear_tramite
-- Tipo: CRUD
-- Descripción: Bloquea un trámite, cancela bloqueos anteriores y registra el nuevo bloqueo.
-- Parámetros entrada: p_id_tramite (INTEGER), p_tipo_bloqueo (INTEGER), p_motivo (LVARCHAR), p_usuario (LVARCHAR)
-- Parámetros salida: success (INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE sp_bloquear_tramite(
    p_id_tramite INTEGER,
    p_tipo_bloqueo INTEGER,
    p_motivo LVARCHAR(500),
    p_usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_bloqueado INTEGER;

    -- Verificar si el trámite existe
    SELECT bloqueado INTO v_bloqueado
    FROM tramites
    WHERE id_tramite = p_id_tramite;

    IF v_bloqueado IS NULL THEN
        RETURN 0, 'No existe el trámite';
    END IF;

    IF v_bloqueado > 0 THEN
        RETURN 0, 'El trámite ya está bloqueado';
    END IF;

    -- Actualizar estado en tramites
    UPDATE tramites
    SET bloqueado = p_tipo_bloqueo
    WHERE id_tramite = p_id_tramite;

    -- Cancelar bloqueos vigentes
    UPDATE bloqueo
    SET vigente = 'C'
    WHERE id_tramite = p_id_tramite AND vigente = 'V';

    -- Insertar nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_tramite, observa, capturista, fecha_mov, vigente)
    VALUES (p_tipo_bloqueo, p_id_tramite, p_motivo, p_usuario, TODAY, 'V');

    RETURN 1, 'Trámite bloqueado correctamente';

END PROCEDURE;

-- SP 6/6: sp_consultar_historial_tramite
-- Tipo: Catalog
-- Descripción: Consulta el historial de bloqueos de un trámite específico.
-- Parámetros entrada: p_id_tramite (INTEGER)
-- Parámetros salida: id_bloqueo, bloqueado, estado, capturista, fecha_mov, vigente, observa
-- --------------------------------------------

CREATE PROCEDURE sp_consultar_historial_tramite(p_id_tramite INTEGER)
RETURNING INTEGER AS id_bloqueo,
          INTEGER AS bloqueado,
          LVARCHAR(20) AS estado,
          LVARCHAR(50) AS capturista,
          DATE AS fecha_mov,
          LVARCHAR(1) AS vigente,
          LVARCHAR(500) AS observa;

    RETURN
        id_bloqueo,
        bloqueado,
        CASE
            WHEN bloqueado = 0 THEN 'DESBLOQUEADO'
            WHEN bloqueado = 1 THEN 'BLOQUEADO GENERAL'
            WHEN bloqueado = 2 THEN 'ESTADO 1'
            WHEN bloqueado = 3 THEN 'CABARET'
            WHEN bloqueado = 4 THEN 'SUSPENDIDO'
            WHEN bloqueado = 5 THEN 'RESPONSIVA'
            WHEN bloqueado = 6 THEN 'CONVENIADO'
            WHEN bloqueado = 7 THEN 'DESGLOSAR'
            ELSE 'BLOQUEADO'
        END AS estado,
        capturista,
        fecha_mov,
        vigente,
        observa
    FROM bloqueo
    WHERE id_tramite = p_id_tramite
    ORDER BY fecha_mov DESC;

END PROCEDURE;