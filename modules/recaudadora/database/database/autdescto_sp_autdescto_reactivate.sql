-- Stored Procedure: sp_autdescto_reactivate
-- Tipo: CRUD
-- Descripción: Reactiva un descuento de predial cancelado
-- Generado para formulario: autdescto
-- Fecha: 2025-08-26 20:45:21

CREATE OR REPLACE FUNCTION sp_autdescto_reactivate(
    p_id INTEGER,
    p_usuario VARCHAR
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
BEGIN
    UPDATE descpred
    SET fecbaja = NULL,
        captbaja = NULL,
        status = 'V',
        observaciones = COALESCE(observaciones,'') || '\nReactivado por ' || p_usuario
    WHERE id = p_id AND status = 'C';
    RETURN QUERY SELECT p_id, 'Descuento reactivado correctamente';
END;
$$ LANGUAGE plpgsql;