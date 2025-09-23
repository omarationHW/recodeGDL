-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REGHFRM (EXACTO del archivo original)
-- Archivo: 82_SP_LICENCIAS_REGHFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REGHFRM (EXACTO del archivo original)
-- Archivo: 82_SP_LICENCIAS_REGHFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: REGHFRM (EXACTO del archivo original)
-- Archivo: 82_SP_LICENCIAS_REGHFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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

