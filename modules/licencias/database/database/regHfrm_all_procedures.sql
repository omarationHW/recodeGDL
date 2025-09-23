-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: regHfrm
-- Generado: 2025-08-27 19:06:01
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_historic_records
-- Tipo: Report
-- Descripción: Obtiene todos los registros históricos (h_catastro) para una cuenta cvecuenta.
-- --------------------------------------------

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

-- ============================================

-- SP 2/5: sp_get_historic_record
-- Tipo: Report
-- Descripción: Obtiene un registro histórico específico por cvecuenta, axocomp y nocomp.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_historic_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS TABLE(cvecuenta INTEGER, axocomp INTEGER, nocomp INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, axocomp, nocomp
    FROM h_catastro
    WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_create_historic_record
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro histórico en h_catastro.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_create_historic_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS VOID AS $$
BEGIN
    INSERT INTO h_catastro (cvecuenta, axocomp, nocomp)
    VALUES (p_cvecuenta, p_axocomp, p_nocomp);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_update_historic_record
-- Tipo: CRUD
-- Descripción: Actualiza un registro histórico existente en h_catastro.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_historic_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER, p_new_axocomp INTEGER, p_new_nocomp INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE h_catastro
    SET axocomp = p_new_axocomp, nocomp = p_new_nocomp
    WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_delete_historic_record
-- Tipo: CRUD
-- Descripción: Elimina un registro histórico de h_catastro.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_historic_record(p_cvecuenta INTEGER, p_axocomp INTEGER, p_nocomp INTEGER)
RETURNS VOID AS $$
BEGIN
    DELETE FROM h_catastro WHERE cvecuenta = p_cvecuenta AND axocomp = p_axocomp AND nocomp = p_nocomp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

