-- Stored Procedure: sp_autdescto_cancel
-- Tipo: CRUD
-- Descripción: Cancela un descuento de predial
-- Generado para formulario: autdescto
-- Fecha: 2025-08-26 20:45:21

CREATE OR REPLACE FUNCTION sp_autdescto_cancel(
    p_id INTEGER,
    p_usuario VARCHAR,
    p_motivo VARCHAR
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
BEGIN
    UPDATE descpred
    SET fecbaja = CURRENT_DATE,
        captbaja = p_usuario,
        status = 'C',
        observaciones = COALESCE(observaciones,'') || '\nCancelado: ' || p_motivo
    WHERE id = p_id AND fecbaja IS NULL;
    RETURN QUERY SELECT p_id, 'Descuento cancelado correctamente';
END;
$$ LANGUAGE plpgsql;