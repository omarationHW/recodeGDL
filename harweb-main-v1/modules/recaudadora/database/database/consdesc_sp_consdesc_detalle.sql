-- Stored Procedure: sp_consdesc_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de un descuento por folio
-- Generado para formulario: consdesc
-- Fecha: 2025-08-26 23:20:34

CREATE OR REPLACE FUNCTION sp_consdesc_detalle(p_foliodesc INTEGER)
RETURNS TABLE (
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini SMALLINT,
    bimfin SMALLINT,
    fecalta DATE,
    captalta TEXT,
    fecbaja DATE,
    captbaja TEXT,
    propie TEXT,
    solicitante TEXT,
    observaciones TEXT,
    recaud_desc SMALLINT,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion SMALLINT,
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.recaud, a.urbrus, a.cuenta, d.*, c.descripcion
    FROM descpred d
    JOIN convcta a ON d.cvecuenta = a.cvecuenta
    JOIN c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE d.foliodesc = p_foliodesc;
END;
$$ LANGUAGE plpgsql;