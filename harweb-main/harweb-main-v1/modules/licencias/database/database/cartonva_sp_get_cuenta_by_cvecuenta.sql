-- Stored Procedure: sp_get_cuenta_by_cvecuenta
-- Tipo: Catalog
-- Descripción: Obtiene la información de la cuenta catastral por cvecuenta
-- Generado para formulario: cartonva
-- Fecha: 2025-08-27 16:43:36

CREATE OR REPLACE FUNCTION sp_get_cuenta_by_cvecuenta(p_cvecuenta INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY SELECT cvecuenta, cvemunicipio, recaud, urbrus, cuenta, digver, zonaanter, manzanter, loteanter, cvecatnva, subpredio, crec, cur, ccta, cip, vigente, cvelocalidad, coordenada_x, coordenada_y
    FROM convcta WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;