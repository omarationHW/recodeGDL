-- Stored Procedure: sp_descpred_delete
-- Tipo: CRUD
-- Descripción: Da de baja (cancela) un descuento de predial
-- Generado para formulario: descpredfrm
-- Fecha: 2025-08-27 21:10:43

CREATE OR REPLACE FUNCTION sp_descpred_delete(
    p_id INTEGER,
    p_motivo TEXT,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
BEGIN
    UPDATE descpred SET
        status = 'C',
        fecbaja = NOW(),
        captbaja = p_user,
        observaciones = COALESCE(observaciones, '') || '\nBAJA: ' || p_motivo
    WHERE id = p_id;
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;