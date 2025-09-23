-- Stored Procedure: sp_get_historic_record
-- Tipo: Report
-- Descripción: Obtiene un registro histórico específico por cvecuenta, axocomp y nocomp.
-- Generado para formulario: regHfrm
-- Fecha: 2025-08-27 19:06:01

CREATE OR REPLACE FUNCTION sp_get_historic_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS TABLE(cvecuenta INTEGER, axocomp INTEGER, nocomp INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, axocomp, nocomp
    FROM h_catastro
    WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;
END;
$$ LANGUAGE plpgsql;