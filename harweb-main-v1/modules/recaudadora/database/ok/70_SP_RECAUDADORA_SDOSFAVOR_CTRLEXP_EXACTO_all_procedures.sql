-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SDOSFAVOR_CTRLEXP (EXACTO del archivo original)
-- Archivo: 70_SP_RECAUDADORA_SDOSFAVOR_CTRLEXP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_sdosfavor_search_folios
-- Tipo: Report
-- Descripción: Obtiene la lista de folios de solic_sdosfavor filtrados por status.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sdosfavor_search_folios(p_status TEXT DEFAULT NULL)
RETURNS TABLE(folio INTEGER, axofol INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT folio, axofol
    FROM solic_sdosfavor
    WHERE (p_status IS NULL OR p_status = '' OR status = p_status)
    ORDER BY folio ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: SDOSFAVOR_CTRLEXP (EXACTO del archivo original)
-- Archivo: 70_SP_RECAUDADORA_SDOSFAVOR_CTRLEXP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_sdosfavor_total_folios
-- Tipo: Report
-- Descripción: Cuenta el total de folios por status.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sdosfavor_total_folios(p_status TEXT DEFAULT NULL)
RETURNS INTEGER AS $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total
  FROM solic_sdosfavor
  WHERE (p_status IS NULL OR p_status = '' OR status = p_status);
  RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- ============================================

