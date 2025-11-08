-- Stored Procedure: sp_reg_h_show
-- Tipo: Report
-- Descripción: Devuelve un registro histórico específico de h_catastro.
-- Generado para formulario: regHfrm
-- Fecha: 2025-08-26 17:41:37

CREATE OR REPLACE FUNCTION sp_reg_h_show(p_cvecuenta integer, p_axocomp integer, p_nocomp integer)
RETURNS TABLE(
    cvecuenta integer,
    axocomp integer,
    nocomp integer,
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
    SELECT cvecuenta, axocomp, nocomp, cvevalor, cveavaluo, cvecartografia, cveregprop, cveubic, observacion, vigente, feccap, capturista
    FROM h_catastro
    WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;
END;
$$ LANGUAGE plpgsql;