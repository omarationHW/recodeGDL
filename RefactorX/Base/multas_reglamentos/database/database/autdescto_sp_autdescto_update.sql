-- Stored Procedure: sp_autdescto_update
-- Tipo: CRUD
-- Descripción: Actualiza un descuento de predial
-- Generado para formulario: autdescto
-- Fecha: 2025-08-26 20:45:21

CREATE OR REPLACE FUNCTION sp_autdescto_update(
    p_id INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_solicitante VARCHAR,
    p_observaciones VARCHAR,
    p_institucion INTEGER,
    p_identificacion VARCHAR,
    p_fecnac DATE,
    p_usuario VARCHAR
) RETURNS TABLE(id INTEGER, message TEXT) AS $$
BEGIN
    UPDATE descpred
    SET bimini = p_bimini,
        bimfin = p_bimfin,
        solicitante = p_solicitante,
        observaciones = p_observaciones,
        institucion = p_institucion,
        identificacion = p_identificacion,
        fecnac = p_fecnac,
        captalta = p_usuario
    WHERE id = p_id;
    RETURN QUERY SELECT p_id, 'Descuento actualizado correctamente';
END;
$$ LANGUAGE plpgsql;