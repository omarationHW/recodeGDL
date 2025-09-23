-- Stored Procedure: sp_autdescto_list
-- Tipo: Catalog
-- Descripción: Lista todos los descuentos de predial para una cuenta
-- Generado para formulario: autdescto
-- Fecha: 2025-08-26 20:45:21

CREATE OR REPLACE FUNCTION sp_autdescto_list(p_cvecuenta INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    fecalta DATE,
    captalta VARCHAR,
    fecbaja DATE,
    captbaja VARCHAR,
    solicitante VARCHAR,
    observaciones VARCHAR,
    recaud INTEGER,
    foliodesc INTEGER,
    status VARCHAR,
    identificacion VARCHAR,
    fecnac DATE,
    institucion INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id, d.cvecuenta, d.cvedescuento, d.bimini, d.bimfin, d.fecalta, d.captalta, d.fecbaja, d.captbaja, d.solicitante, d.observaciones, d.recaud, d.foliodesc, d.status, d.identificacion, d.fecnac, d.institucion, c.descripcion
    FROM descpred d
    JOIN c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE d.cvecuenta = p_cvecuenta
    ORDER BY d.fecalta DESC;
END;
$$ LANGUAGE plpgsql;