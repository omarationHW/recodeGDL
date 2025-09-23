-- Stored Procedure: sp_get_historic_records
-- Tipo: Report
-- Descripción: Obtiene todos los registros históricos (h_catastro) para una cuenta cvecuenta.
-- Generado para formulario: regHfrm
-- Fecha: 2025-08-27 19:06:01

CREATE OR REPLACE FUNCTION sp_get_historic_records(p_cvecuenta INTEGER)
RETURNS TABLE(axocomp INTEGER, nocomp INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT axocomp, nocomp
    FROM h_catastro
    WHERE cvecuenta = p_cvecuenta
    ORDER BY axocomp DESC, nocomp DESC;
END;
$$ LANGUAGE plpgsql;