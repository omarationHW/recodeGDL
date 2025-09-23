-- Stored Procedure: sp_bloquear_tramite
-- Tipo: CRUD
-- Descripción: Bloquea un trámite, cancela el último bloqueo vigente y registra el nuevo bloqueo.
-- Generado para formulario: BloquearTramitefrm
-- Fecha: 2025-08-26 14:42:36

CREATE OR REPLACE FUNCTION sp_bloquear_tramite(p_id_tramite INTEGER, p_observa VARCHAR, p_capturista VARCHAR)
RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Actualizar campo bloqueado en tramite
    UPDATE tramites SET bloqueado = 1 WHERE id_tramite = p_id_tramite;
    -- Cancelar último bloqueo vigente
    UPDATE bloqueo SET vigente = 'C' WHERE id_tramite = p_id_tramite AND vigente = 'V';
    -- Insertar nuevo bloqueo
    INSERT INTO bloqueo (bloqueado, id_tramite, observa, vigente, capturista, fecha_mov)
    VALUES (1, p_id_tramite, p_observa, 'V', p_capturista, CURRENT_DATE);
    RETURN QUERY SELECT TRUE, 'Trámite bloqueado correctamente.';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al bloquear trámite: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;