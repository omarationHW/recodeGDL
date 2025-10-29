-- Stored Procedure: sp_reg_h_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro histórico de h_catastro.
-- Generado para formulario: regHfrm
-- Fecha: 2025-08-26 17:41:37

CREATE OR REPLACE FUNCTION sp_reg_h_delete(p_cvecuenta integer, p_axocomp integer, p_nocomp integer)
RETURNS integer AS $$
DECLARE
    deleted integer;
BEGIN
    DELETE FROM h_catastro WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;
    GET DIAGNOSTICS deleted = ROW_COUNT;
    RETURN deleted;
END;
$$ LANGUAGE plpgsql;