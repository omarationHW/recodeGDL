-- Stored Procedure: sp_insert_descuento_predial
-- Tipo: CRUD
-- Descripción: Inserta un nuevo descuento predial
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-27 21:03:36

CREATE OR REPLACE FUNCTION sp_insert_descuento_predial(
    p_cvecuenta INTEGER,
    p_cvedescuento INTEGER,
    p_bimini INTEGER,
    p_bimfin INTEGER,
    p_fecalta DATE,
    p_captalta TEXT,
    p_solicitante TEXT,
    p_observaciones TEXT,
    p_recaud INTEGER,
    p_foliodesc INTEGER,
    p_status TEXT,
    p_identificacion TEXT DEFAULT NULL,
    p_fecnac DATE DEFAULT NULL,
    p_institucion INTEGER DEFAULT NULL
) RETURNS INTEGER AS $$
DECLARE
    v_id INTEGER;
BEGIN
    INSERT INTO descpred (cvecuenta, cvedescuento, bimini, bimfin, fecalta, captalta, solicitante, observaciones, recaud, foliodesc, status, identificacion, fecnac, institucion)
    VALUES (p_cvecuenta, p_cvedescuento, p_bimini, p_bimfin, p_fecalta, p_captalta, p_solicitante, p_observaciones, p_recaud, p_foliodesc, p_status, p_identificacion, p_fecnac, p_institucion)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;