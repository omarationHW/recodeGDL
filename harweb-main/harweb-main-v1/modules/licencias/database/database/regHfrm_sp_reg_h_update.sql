-- Stored Procedure: sp_reg_h_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro histórico en h_catastro.
-- Generado para formulario: regHfrm
-- Fecha: 2025-08-26 17:41:37

CREATE OR REPLACE FUNCTION sp_reg_h_update(
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
    affected integer;
BEGIN
    UPDATE h_catastro SET
        cvevalor = p_cvevalor,
        cveavaluo = p_cveavaluo,
        cvecartografia = p_cvecartografia,
        cveregprop = p_cveregprop,
        cveubic = p_cveubic,
        observacion = p_observacion,
        vigente = p_vigente,
        feccap = p_feccap,
        capturista = p_capturista
    WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;
    GET DIAGNOSTICS affected = ROW_COUNT;
    RETURN affected;
END;
$$ LANGUAGE plpgsql;