-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: SdosFavor_CtrlExp
-- Generado: 2025-08-27 15:38:42
-- Total SPs: 3
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

-- SP 2/3: sp_sdosfavor_assign_folios
-- Tipo: CRUD
-- Descripción: Asigna un nuevo status a una lista de folios.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_sdosfavor_assign_folios(p_folios INTEGER[], p_new_status TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE solic_sdosfavor
  SET status = p_new_status
  WHERE folio = ANY(p_folios);
END;
$$ LANGUAGE plpgsql;

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

