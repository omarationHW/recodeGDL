-- Stored Procedure: sp_create_historic_record
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro histórico en h_catastro.
-- Generado para formulario: regHfrm
-- Fecha: 2025-08-27 19:06:01

CREATE OR REPLACE FUNCTION sp_create_historic_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS VOID AS $$
BEGIN
    INSERT INTO h_catastro (cvecuenta, axocomp, nocomp)
    VALUES (p_cvecuenta, p_axocomp, p_nocomp);
END;
$$ LANGUAGE plpgsql;