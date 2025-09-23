-- Stored Procedure: sp_reg_h_list
-- Tipo: Report
-- Descripción: Lista los registros históricos de h_catastro para una cuenta catastral.
-- Generado para formulario: regHfrm
-- Fecha: 2025-08-26 17:41:37

CREATE OR REPLACE FUNCTION sp_reg_h_list(p_cvecuenta integer)
RETURNS TABLE(
    axo integer,
    nocomp integer,
    cvecuenta integer,
    cvevalor integer,
    cveavaluo integer,
    cvecartografia integer,
    cveregprop integer,
    cveubic integer,
    observacion text,
    vigente varchar,
    feccap date,
    capturista varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT axocomp, nocomp, cvecuenta, cvevalor, cveavaluo, cvecartografia, cveregprop, cveubic, observacion, vigente, feccap, capturista
    FROM h_catastro
    WHERE cvecuenta = p_cvecuenta
    ORDER BY axocomp DESC, nocomp DESC;
END;
$$ LANGUAGE plpgsql;