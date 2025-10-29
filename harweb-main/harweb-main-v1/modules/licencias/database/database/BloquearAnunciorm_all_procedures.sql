-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: BloquearAnunciorm
-- Generado: 2025-08-27 16:01:27
-- Total SPs: 4
-- ============================================

-- SP 1/4: buscar_anuncio
-- Tipo: Catalog
-- Descripción: Busca un anuncio por su número y devuelve todos sus datos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_anuncio(numero_anuncio TEXT)
RETURNS TABLE (
    id_anuncio INTEGER,
    id_licencia INTEGER,
    fecha_otorgamiento DATE,
    medidas1 TEXT,
    medidas2 TEXT,
    area_anuncio NUMERIC,
    ubicacion TEXT,
    numext_ubic TEXT,
    letraext_ubic TEXT,
    numint_ubic TEXT,
    letraint_ubic TEXT,
    bloqueado INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
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
    WHERE anuncio = numero_anuncio::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: consultar_bloqueos
-- Tipo: Catalog
-- Descripción: Consulta todos los movimientos de bloqueo/desbloqueo de un anuncio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION consultar_bloqueos(id_anuncio INTEGER)
RETURNS TABLE (
    id_tramite INTEGER,
    id_licencia INTEGER,
    bloqueado SMALLINT,
    capturista TEXT,
    fecha_mov DATE,
    observa TEXT,
    estado TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        id_tramite,
        id_licencia,
        bloqueado,
        capturista,
        fecha_mov,
        observa,
        CASE WHEN bloqueado = 1 THEN 'BLOQUEADO' ELSE 'NO BLOQUEADO' END AS estado
    FROM bloqueo
    WHERE id_anuncio = consultar_bloqueos.id_anuncio
    ORDER BY fecha_mov DESC, id_tramite DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: bloquear_anuncio
-- Tipo: CRUD
-- Descripción: Bloquea un anuncio, cancela el último movimiento vigente y registra el nuevo bloqueo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION bloquear_anuncio(
    id_anuncio INTEGER,
    observa TEXT,
    usuario TEXT
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_bloqueado INTEGER;
BEGIN
    SELECT bloqueado INTO v_bloqueado FROM anuncios WHERE id_anuncio = bloquear_anuncio.id_anuncio;
    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el anuncio';
        RETURN;
    END IF;
    IF v_bloqueado > 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio ya está bloqueado, no se puede bloquear';
        RETURN;
    END IF;
    -- Actualiza el estado del anuncio
    UPDATE anuncios SET bloqueado = 1 WHERE id_anuncio = bloquear_anuncio.id_anuncio;
    -- Cancela el último registro vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_anuncio = bloquear_anuncio.id_anuncio AND vigente = 'V';
    -- Registra el nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_anuncio, observa, capturista, fecha_mov, vigente)
    VALUES (1, bloquear_anuncio.id_anuncio, observa, usuario, CURRENT_DATE, 'V');
    RETURN QUERY SELECT TRUE, 'Anuncio bloqueado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: desbloquear_anuncio
-- Tipo: CRUD
-- Descripción: Desbloquea un anuncio, cancela el último movimiento vigente y registra el nuevo desbloqueo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION desbloquear_anuncio(
    id_anuncio INTEGER,
    observa TEXT,
    usuario TEXT
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_bloqueado INTEGER;
BEGIN
    SELECT bloqueado INTO v_bloqueado FROM anuncios WHERE id_anuncio = desbloquear_anuncio.id_anuncio;
    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el anuncio';
        RETURN;
    END IF;
    IF v_bloqueado = 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio no está bloqueado, no se puede desbloquear';
        RETURN;
    END IF;
    -- Actualiza el estado del anuncio
    UPDATE anuncios SET bloqueado = 0 WHERE id_anuncio = desbloquear_anuncio.id_anuncio;
    -- Cancela el último registro vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_anuncio = desbloquear_anuncio.id_anuncio AND vigente = 'V';
    -- Registra el nuevo desbloqueo
    INSERT INTO bloqueo (bloqueado, id_anuncio, observa, capturista, fecha_mov, vigente)
    VALUES (0, desbloquear_anuncio.id_anuncio, observa, usuario, CURRENT_DATE, 'V');
    RETURN QUERY SELECT TRUE, 'Anuncio desbloqueado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

