-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSUEM400 (EXACTO del archivo original)
-- Archivo: 44_SP_RECAUDADORA_CONSUEM400_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_cons_uem400_by_comprobante
-- Tipo: Report
-- Descripción: Consulta historico y comp_400 por año y comprobante
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cons_uem400_by_comprobante(anio integer, comprob integer)
RETURNS TABLE(
  historico jsonb,
  comp_400 jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      (SELECT jsonb_agg(row_to_json(h)) FROM historico h WHERE h.recaud = 0) AS historico,
      (SELECT jsonb_agg(row_to_json(c)) FROM comp_400 c WHERE c.axocomc = LPAD(anio::text, 4, '0') AND c.comproc = LPAD(comprob::text, 6, '0')) AS comp_400;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: CONSUEM400 (EXACTO del archivo original)
-- Archivo: 44_SP_RECAUDADORA_CONSUEM400_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

