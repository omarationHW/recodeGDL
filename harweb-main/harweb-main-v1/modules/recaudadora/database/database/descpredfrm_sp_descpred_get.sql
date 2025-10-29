-- Stored Procedure: sp_descpred_get
-- Tipo: CRUD
-- Descripción: Obtiene un descuento de predial por ID
-- Generado para formulario: descpredfrm
-- Fecha: 2025-08-27 21:10:43

CREATE OR REPLACE FUNCTION sp_descpred_get(p_id INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvecuenta INTEGER,
    cvedescuento INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    fecalta DATE,
    captalta TEXT,
    fecbaja DATE,
    captbaja TEXT,
    propie TEXT,
    solicitante TEXT,
    observaciones TEXT,
    recaud INTEGER,
    foliodesc INTEGER,
    status TEXT,
    identificacion TEXT,
    fecnac DATE,
    institucion INTEGER,
    porcentaje INTEGER,
    descripcion TEXT,
    institucion_nombre TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT d.id, d.cvecuenta, d.cvedescuento, d.bimini, d.bimfin, d.fecalta, d.captalta, d.fecbaja, d.captbaja, d.propie, d.solicitante, d.observaciones, d.recaud, d.foliodesc, d.status, d.identificacion, d.fecnac, d.institucion, d.porcentaje, c.descripcion, i.institucion
    FROM descpred d
    JOIN c_descpred c ON d.cvedescuento = c.cvedescuento
    LEFT JOIN c_instituciones i ON d.institucion = i.cveinst
    WHERE d.id = p_id;
END;
$$ LANGUAGE plpgsql;