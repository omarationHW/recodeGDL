-- Stored Procedure: bloquear_tramite
-- Tipo: CRUD
-- Descripción: Bloquea un trámite, cancela el último bloqueo vigente y registra el nuevo bloqueo.
-- Generado para formulario: BloquearTramitefrm
-- Fecha: 2025-08-27 16:06:44

CREATE OR REPLACE FUNCTION bloquear_tramite(p_id_tramite integer, p_observa varchar, p_capturista varchar)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_count integer;
BEGIN
    -- Actualizar campo bloqueado en tramites
    UPDATE tramites SET bloqueado = 1 WHERE id_tramite = p_id_tramite;
    -- Cancelar último bloqueo vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_tramite = p_id_tramite AND vigente = 'V';
    -- Insertar nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_tramite, observa, capturista, fecha_mov, vigente)
    VALUES (1, p_id_tramite, p_observa, p_capturista, CURRENT_DATE, 'V');
    RETURN QUERY SELECT true, 'Trámite bloqueado correctamente';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al bloquear trámite: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;