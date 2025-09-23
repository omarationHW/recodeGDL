-- Stored Procedure: desbloquear_anuncio
-- Tipo: CRUD
-- Descripción: Desbloquea un anuncio, cancela el último movimiento vigente y registra el nuevo desbloqueo.
-- Generado para formulario: BloquearAnunciorm
-- Fecha: 2025-08-27 16:01:27

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