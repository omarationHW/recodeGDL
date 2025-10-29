-- Stored Procedure: sp_desbloquear_anuncio
-- Tipo: CRUD
-- Descripción: Desbloquea un anuncio, cancela el último registro vigente y agrega un nuevo movimiento de desbloqueo.
-- Generado para formulario: BloquearAnunciorm
-- Fecha: 2025-08-26 14:36:16

CREATE OR REPLACE FUNCTION sp_desbloquear_anuncio(p_id_anuncio INTEGER, p_observa VARCHAR, p_usuario VARCHAR)
RETURNS TABLE (id_anuncio INTEGER, bloqueado INTEGER) AS $$
DECLARE
    v_bloqueado INTEGER;
BEGIN
    -- Verifica si ya está desbloqueado
    SELECT bloqueado INTO v_bloqueado FROM anuncios WHERE id_anuncio = p_id_anuncio;
    IF v_bloqueado IS NULL THEN
        RAISE EXCEPTION 'No existe el anuncio';
    END IF;
    IF v_bloqueado = 0 THEN
        RAISE EXCEPTION 'El anuncio no está bloqueado, no se puede desbloquear';
    END IF;

    -- Actualiza el estado del anuncio
    UPDATE anuncios SET bloqueado = 0 WHERE id_anuncio = p_id_anuncio;

    -- Cancela el último registro vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_anuncio = p_id_anuncio AND vigente = 'V';

    -- Inserta el nuevo movimiento de desbloqueo
    INSERT INTO bloqueo (bloqueado, id_anuncio, observa, capturista, fecha_mov, vigente)
    VALUES (0, p_id_anuncio, p_observa, p_usuario, CURRENT_DATE, 'V');

    RETURN QUERY SELECT p_id_anuncio, 0;
END;
$$ LANGUAGE plpgsql;