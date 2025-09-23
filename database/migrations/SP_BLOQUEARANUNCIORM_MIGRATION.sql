-- ============================================
-- MIGRACIÓN DE STORED PROCEDURES - BLOQUEARANUNCIORM
-- Base de datos: padron_licencias
-- Esquema: informix
-- Generado: 2025-09-22
-- ============================================

\c padron_licencias;
SET search_path TO informix;

-- ============================================
-- SP 1/2: buscar_anuncio
-- Descripción: Busca un anuncio por su número y devuelve todos sus datos
-- ============================================

CREATE OR REPLACE FUNCTION informix.buscar_anuncio(numero_anuncio TEXT)
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
        a.id_anuncio,
        a.id_licencia,
        a.fecha_otorgamiento,
        a.medidas1,
        a.medidas2,
        a.area_anuncio,
        a.ubicacion,
        a.numext_ubic,
        a.letraext_ubic,
        a.numint_ubic,
        a.letraint_ubic,
        a.bloqueado
    FROM informix.anuncios a
    WHERE a.anuncio = numero_anuncio::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/2: bloquear_anuncio
-- Descripción: Bloquea un anuncio, cancela el último movimiento vigente y registra el nuevo bloqueo
-- ============================================

CREATE OR REPLACE FUNCTION informix.bloquear_anuncio(
    id_anuncio INTEGER,
    observa TEXT,
    usuario TEXT
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_bloqueado INTEGER;
BEGIN
    -- Verificar si el anuncio existe
    SELECT bloqueado INTO v_bloqueado FROM informix.anuncios WHERE id_anuncio = bloquear_anuncio.id_anuncio;

    IF v_bloqueado IS NULL THEN
        RETURN QUERY SELECT FALSE, 'No existe el anuncio';
        RETURN;
    END IF;

    IF v_bloqueado > 0 THEN
        RETURN QUERY SELECT FALSE, 'El anuncio ya está bloqueado, no se puede bloquear';
        RETURN;
    END IF;

    -- Actualiza el estado del anuncio
    UPDATE informix.anuncios SET bloqueado = 1 WHERE id_anuncio = bloquear_anuncio.id_anuncio;

    -- Cancela el último registro vigente
    UPDATE informix.bloqueo SET vigente = 'C' WHERE id_anuncio = bloquear_anuncio.id_anuncio AND vigente = 'V';

    -- Registra el nuevo bloqueo
    INSERT INTO informix.bloqueo (bloqueado, id_anuncio, observa, capturista, fecha_mov, vigente)
    VALUES (1, bloquear_anuncio.id_anuncio, observa, usuario, CURRENT_DATE, 'V');

    RETURN QUERY SELECT TRUE, 'Anuncio bloqueado correctamente';

EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al bloquear anuncio: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMENTARIOS DE USO
-- ============================================
-- 1. Buscar anuncio: SELECT * FROM informix.buscar_anuncio('12345');
-- 2. Bloquear anuncio: SELECT * FROM informix.bloquear_anuncio(1, 'Motivo del bloqueo', 'usuario_sistema');