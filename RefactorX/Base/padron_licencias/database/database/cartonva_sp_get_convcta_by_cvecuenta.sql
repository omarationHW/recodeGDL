-- Stored Procedure: sp_get_convcta_by_cvecuenta
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la cuenta catastral por cvecuenta
-- Generado para formulario: cartonva
-- Fecha: 2025-08-26 15:12:01

CREATE OR REPLACE FUNCTION sp_get_convcta_by_cvecuenta(p_cvecuenta INTEGER)
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
    coordenada_y DOUBLE PRECISION,
    por_construccion VARCHAR(1),
    crea_fecha TIMESTAMP,
    crea_usuario VARCHAR(15),
    crea_computer VARCHAR(50),
    baja_fecha TIMESTAMP,
    baja_usuario VARCHAR(15),
    baja_computer VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY SELECT * FROM convcta WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;