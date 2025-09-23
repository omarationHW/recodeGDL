-- Stored Procedure: sp_reg_h_create
-- Tipo: CRUD
-- Descripción: Crea un registro histórico en h_catastro.
-- Generado para formulario: regHfrm
-- Fecha: 2025-08-26 17:41:37

CREATE OR REPLACE FUNCTION sp_reg_h_create(
    p_cvecuenta integer,
    p_axocomp integer,
    p_nocomp integer,
    p_cvevalor integer,
    p_cveavaluo integer,
    p_cvecartografia integer,
    p_cveregprop integer,
    p_cveubic integer,
    p_observacion text,
    p_vigente varchar,
    p_feccap date,
    p_capturista varchar
) RETURNS integer AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO h_catastro (cvecuenta, axocomp, nocomp, cvevalor, cveavaluo, cvecartografia, cveregprop, cveubic, observacion, vigente, feccap, capturista)
    VALUES (p_cvecuenta, p_axocomp, p_nocomp, p_cvevalor, p_cveavaluo, p_cvecartografia, p_cveregprop, p_cveubic, p_observacion, p_vigente, p_feccap, p_capturista)
    RETURNING nocomp INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;