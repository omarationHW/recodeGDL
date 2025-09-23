-- Stored Procedure: sp_consdesc_search
-- Tipo: Report
-- Descripción: Búsqueda avanzada de descuentos prediales
-- Generado para formulario: consdesc
-- Fecha: 2025-08-26 23:20:34

CREATE OR REPLACE FUNCTION sp_consdesc_search(
    p_propi TEXT DEFAULT NULL,
    p_foliodesc INTEGER DEFAULT NULL,
    p_recaud INTEGER DEFAULT NULL,
    p_identificacion TEXT DEFAULT NULL,
    p_solicitante TEXT DEFAULT NULL,
    p_institucion INTEGER DEFAULT NULL
) RETURNS TABLE (
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
    WHERE (p_propi IS NULL OR d.propie ILIKE '%' || p_propi || '%')
      AND (p_foliodesc IS NULL OR d.foliodesc = p_foliodesc)
      AND (p_recaud IS NULL OR d.recaud = p_recaud)
      AND (p_identificacion IS NULL OR d.identificacion ILIKE '%' || p_identificacion || '%')
      AND (p_solicitante IS NULL OR d.solicitante ILIKE '%' || p_solicitante || '%')
      AND (p_institucion IS NULL OR d.institucion = p_institucion)
    ORDER BY d.propie;
END;
$$ LANGUAGE plpgsql;