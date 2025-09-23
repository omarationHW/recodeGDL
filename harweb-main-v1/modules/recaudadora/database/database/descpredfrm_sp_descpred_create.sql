-- Stored Procedure: sp_descpred_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo descuento de predial
-- Generado para formulario: descpredfrm
-- Fecha: 2025-08-27 21:10:43

CREATE OR REPLACE FUNCTION sp_descpred_create(
    p_cvecuenta INTEGER,
    p_cvedescuento INTEGER,
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
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO descpred (
        cvecuenta, cvedescuento, bimini, bimfin, solicitante, identificacion, fecnac, institucion, observaciones, porcentaje, fecalta, captalta, status
    ) VALUES (
        p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin, p_solicitante, p_identificacion, p_fecnac, p_institucion, p_observaciones, p_porcentaje, NOW(), p_user, 'V'
    ) RETURNING id INTO v_id;
    RETURN QUERY SELECT v_id;
END;
$$ LANGUAGE plpgsql;