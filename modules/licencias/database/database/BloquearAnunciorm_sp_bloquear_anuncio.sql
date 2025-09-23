-- Stored Procedure: sp_bloquear_anuncio
-- Tipo: CRUD
-- Descripción: Bloquea un anuncio, cancela el último registro vigente y agrega un nuevo movimiento de bloqueo.
-- Generado para formulario: BloquearAnunciorm
-- Fecha: 2025-08-26 14:36:16

CREATE OR REPLACE FUNCTION sp_bloquear_anuncio(p_id_anuncio INTEGER, p_observa VARCHAR, p_usuario VARCHAR)
RETURNS TABLE (id_anuncio INTEGER, bloqueado INTEGER) AS $$
DECLARE
    v_bloqueado INTEGER;
BEGIN
    -- Verifica si ya está bloqueado
    SELECT bloqueado INTO v_bloqueado FROM anuncios WHERE id_anuncio = p_id_anuncio;
    IF v_bloqueado IS NULL THEN
        RAISE EXCEPTION 'No existe el anuncio';
    END IF;
    IF v_bloqueado = 1 THEN
        RAISE EXCEPTION 'El anuncio ya está bloqueado, no se puede bloquear';
    END IF;

    -- Actualiza el estado del anuncio
    UPDATE anuncios SET bloqueado = 1 WHERE id_anuncio = p_id_anuncio;

    -- Cancela el último registro vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_anuncio = p_id_anuncio AND vigente = 'V';

    -- Inserta el nuevo movimiento de bloqueo
    INSERT INTO bloqueo (bloqueado, id_anuncio, observa, capturista, fecha_mov, vigente)
    VALUES (1, p_id_anuncio, p_observa, p_usuario, CURRENT_DATE, 'V');

    RETURN QUERY SELECT p_id_anuncio, 1;
END;
$$ LANGUAGE plpgsql;