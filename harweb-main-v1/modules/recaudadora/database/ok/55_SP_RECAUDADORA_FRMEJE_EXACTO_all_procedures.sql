-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: FRMEJE (EXACTO del archivo original)
-- Archivo: 55_SP_RECAUDADORA_FRMEJE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_eje_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo ejecutor
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_eje_create(
    p_paterno TEXT,
    p_materno TEXT,
    p_nombres TEXT,
    p_rfc TEXT,
    p_recaud INTEGER,
    p_oficio TEXT,
    p_fecing DATE,
    p_fecinic DATE,
    p_fecterm DATE,
    p_capturista TEXT
) RETURNS TABLE(cveejecutor INTEGER) AS $$
DECLARE
    new_id INTEGER;
BEGIN
    INSERT INTO ejecutores (paterno, materno, nombres, rfc, recaud, oficio, fecing, fecinic, fecterm, capturista, vigente, feccap)
    VALUES (p_paterno, p_materno, p_nombres, p_rfc, p_recaud, p_oficio, p_fecing, p_fecinic, p_fecterm, p_capturista, 'V', NOW())
    RETURNING cveejecutor INTO new_id;
    RETURN QUERY SELECT new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: FRMEJE (EXACTO del archivo original)
-- Archivo: 55_SP_RECAUDADORA_FRMEJE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_eje_delete
-- Tipo: CRUD
-- Descripción: Elimina un ejecutor (baja lógica)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_eje_delete(p_id INTEGER) RETURNS TABLE(deleted BOOLEAN) AS $$
BEGIN
    UPDATE ejecutores SET vigente = 'C', fecbaj = NOW() WHERE cveejecutor = p_id;
    RETURN QUERY SELECT FOUND();
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: FRMEJE (EXACTO del archivo original)
-- Archivo: 55_SP_RECAUDADORA_FRMEJE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

