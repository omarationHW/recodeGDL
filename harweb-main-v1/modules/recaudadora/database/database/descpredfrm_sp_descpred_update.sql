-- Stored Procedure: sp_descpred_update
-- Tipo: CRUD
-- Descripción: Actualiza un descuento de predial existente
-- Generado para formulario: descpredfrm
-- Fecha: 2025-08-27 21:10:43

CREATE OR REPLACE FUNCTION sp_descpred_update(
    p_id INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante TEXT,
    p_identificacion TEXT,
    p_fecnac DATE,
    p_institucion INTEGER,
    p_observaciones TEXT,
    p_porcentaje INTEGER,
    p_user TEXT
) RETURNS TABLE(id INTEGER) AS $$
BEGIN
    UPDATE descpred SET
        bimini = p_bimini,
        bimfin = p_bimfin,
        solicitante = p_solicitante,
        identificacion = p_identificacion,
        fecnac = p_fecnac,
        institucion = p_institucion,
        observaciones = p_observaciones,
        porcentaje = p_porcentaje,
        captbaja = NULL,
        fecbaja = NULL
    WHERE id = p_id;
    RETURN QUERY SELECT p_id;
END;
$$ LANGUAGE plpgsql;