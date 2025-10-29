-- Stored Procedure: sp_descpred_reactivate
-- Tipo: CRUD
-- Descripción: Reactiva un descuento de predial dado de baja
-- Generado para formulario: descpredfrm
-- Fecha: 2025-08-27 21:10:43

CREATE OR REPLACE FUNCTION sp_descpred_reactivate(
    p_id INTEGER,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
BEGIN
    UPDATE descpred SET
        status = 'V',
        fecbaja = NULL,
        captbaja = NULL
    WHERE id = p_id;
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;