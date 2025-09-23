-- Stored Procedure: sp_get_descuentos_predial
-- Tipo: Report
-- Descripción: Obtiene los descuentos predial de una cuenta
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-27 21:03:36

CREATE OR REPLACE FUNCTION sp_get_descuentos_predial(p_cvecuenta INTEGER)
RETURNS TABLE(
    id INTEGER,
    cvedescuento INTEGER,
    bimini INTEGER,
    bimfin INTEGER,
    solicitante TEXT,
    observaciones TEXT,
    fecalta DATE,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY SELECT id, cvedescuento, bimini, bimfin, solicitante, observaciones, fecalta, status
    FROM descpred WHERE cvecuenta = p_cvecuenta ORDER BY fecalta DESC;
END;
$$ LANGUAGE plpgsql;