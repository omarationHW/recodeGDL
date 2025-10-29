-- ============================================
-- STORED PROCEDURES MIGRADOS - INFORMIX
-- Formulario: BLOQUEARANUNCIORM
-- Archivo: 06_SP_LICENCIAS_BLOQUEARANUNCIORM_INFORMIX.sql
-- Migración desde PostgreSQL a INFORMIX
-- Fecha: 2025-09-23
-- Total SPs: 4
-- ============================================

-- SP 1/2: buscar_anuncio
-- Tipo: Catalog
-- Descripción: Busca un anuncio por su número y devuelve todos sus datos.
-- Parámetros entrada: numero_anuncio (INTEGER)
-- Parámetros salida: id_anuncio, id_licencia, fecha_otorgamiento, medidas1, medidas2, area_anuncio, ubicacion, numext_ubic, letraext_ubic, numint_ubic, letraint_ubic, bloqueado
-- --------------------------------------------

CREATE PROCEDURE buscar_anuncio(numero_anuncio INTEGER)
RETURNING INTEGER AS id_anuncio,
          INTEGER AS id_licencia,
          DATE AS fecha_otorgamiento,
          LVARCHAR(255) AS medidas1,
          LVARCHAR(255) AS medidas2,
          DECIMAL(10,2) AS area_anuncio,
          LVARCHAR(255) AS ubicacion,
          LVARCHAR(50) AS numext_ubic,
          LVARCHAR(50) AS letraext_ubic,
          LVARCHAR(50) AS numint_ubic,
          LVARCHAR(50) AS letraint_ubic,
          INTEGER AS bloqueado;

    RETURN
        id_anuncio,
        id_licencia,
        fecha_otorgamiento,
        medidas1,
        medidas2,
        area_anuncio,
        ubicacion,
        numext_ubic,
        letraext_ubic,
        numint_ubic,
        letraint_ubic,
        bloqueado
    FROM anuncios
    WHERE anuncio = numero_anuncio;

END PROCEDURE;

-- SP 2/2: bloquear_anuncio
-- Tipo: CRUD
-- Descripción: Bloquea un anuncio, cancela el último movimiento vigente y registra el nuevo bloqueo.
-- Parámetros entrada: id_anuncio (INTEGER), observa (LVARCHAR), usuario (LVARCHAR)
-- Parámetros salida: success (BOOLEAN simulado con INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE bloquear_anuncio(
    p_id_anuncio INTEGER,
    observa LVARCHAR(500),
    usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_bloqueado INTEGER;

    -- Verificar si existe el anuncio y obtener estado de bloqueo
    SELECT bloqueado INTO v_bloqueado
    FROM anuncios
    WHERE id_anuncio = p_id_anuncio;

    -- Si no existe el anuncio
    IF v_bloqueado IS NULL THEN
        RETURN 0, 'No existe el anuncio';
    END IF;

    -- Si ya está bloqueado
    IF v_bloqueado > 0 THEN
        RETURN 0, 'El anuncio ya está bloqueado, no se puede bloquear';
    END IF;

    -- Actualiza el estado del anuncio
    UPDATE anuncios
    SET bloqueado = 1
    WHERE id_anuncio = p_id_anuncio;

    -- Cancela el último registro vigente
    UPDATE bloqueo
    SET vigente = 'C'
    WHERE id_anuncio = p_id_anuncio AND vigente = 'V';

    -- Registra el nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_anuncio, observa, capturista, fecha_mov, vigente)
    VALUES (1, p_id_anuncio, observa, usuario, TODAY, 'V');

    RETURN 1, 'Anuncio bloqueado correctamente';

END PROCEDURE;

-- SP 3/4: desbloquear_anuncio
-- Tipo: CRUD
-- Descripción: Desbloquea un anuncio, cancela el último movimiento vigente y registra el nuevo desbloqueo.
-- Parámetros entrada: id_anuncio (INTEGER), observa (LVARCHAR), usuario (LVARCHAR)
-- Parámetros salida: success (BOOLEAN simulado con INTEGER), message (LVARCHAR)
-- --------------------------------------------

CREATE PROCEDURE desbloquear_anuncio(
    p_id_anuncio INTEGER,
    observa LVARCHAR(500),
    usuario LVARCHAR(50)
)
RETURNING INTEGER AS success,
          LVARCHAR(255) AS message;

DEFINE v_bloqueado INTEGER;

    -- Verificar si existe el anuncio y obtener estado de bloqueo
    SELECT bloqueado INTO v_bloqueado
    FROM anuncios
    WHERE id_anuncio = p_id_anuncio;

    -- Si no existe el anuncio
    IF v_bloqueado IS NULL THEN
        RETURN 0, 'No existe el anuncio';
    END IF;

    -- Si no está bloqueado
    IF v_bloqueado = 0 THEN
        RETURN 0, 'El anuncio no está bloqueado, no se puede desbloquear';
    END IF;

    -- Actualiza el estado del anuncio
    UPDATE anuncios
    SET bloqueado = 0
    WHERE id_anuncio = p_id_anuncio;

    -- Cancela el último registro vigente
    UPDATE bloqueo
    SET vigente = 'C'
    WHERE id_anuncio = p_id_anuncio AND vigente = 'V';

    -- Registra el nuevo desbloqueo
    INSERT INTO bloqueo (bloqueado, id_anuncio, observa, capturista, fecha_mov, vigente)
    VALUES (0, p_id_anuncio, observa, usuario, TODAY, 'V');

    RETURN 1, 'Anuncio desbloqueado correctamente';

END PROCEDURE;

-- SP 4/4: consultar_bloqueos
-- Tipo: Catalog
-- Descripción: Consulta el historial de bloqueos de un anuncio específico.
-- Parámetros entrada: id_anuncio (INTEGER)
-- Parámetros salida: id_bloqueo, bloqueado, estado, capturista, fecha_mov, observa
-- --------------------------------------------

CREATE PROCEDURE consultar_bloqueos(id_anuncio INTEGER)
RETURNING INTEGER AS id_bloqueo,
          INTEGER AS bloqueado,
          LVARCHAR(20) AS estado,
          LVARCHAR(50) AS capturista,
          DATE AS fecha_mov,
          LVARCHAR(500) AS observa;

    RETURN
        id_bloqueo,
        bloqueado,
        CASE WHEN bloqueado = 1 THEN 'BLOQUEADO' ELSE 'DESBLOQUEADO' END AS estado,
        capturista,
        fecha_mov,
        observa
    FROM bloqueo
    WHERE id_anuncio = consultar_bloqueos.id_anuncio
    ORDER BY fecha_mov DESC;

END PROCEDURE;