-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsUem400 (Consulta UEM 400)
-- Generado: 2025-08-26 23:48:20
-- Total SPs: 2
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
      (SELECT jsonb_agg(row_to_json(h)) 
       FROM public.historico h 
       WHERE h.recaud = 0) AS historico,
      (SELECT jsonb_agg(row_to_json(c)) 
       FROM public.comp_400 c 
       WHERE c.axocomc = LPAD(anio::text, 4, '0') 
         AND c.comproc = LPAD(comprob::text, 6, '0')) AS comp_400;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_cons_uem400_by_cuenta
-- Tipo: Report
-- Descripción: Consulta historico y comp_400 por recaud, ur, cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cons_uem400_by_cuenta(recaud integer, ur text, cuenta integer)
RETURNS TABLE(
  historico jsonb,
  comp_400 jsonb
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      (SELECT jsonb_agg(row_to_json(h)) 
       FROM public.historico h 
       WHERE h.recaud = LPAD(recaud::text, 3, '0') 
         AND h.ur = ur 
         AND h.cuenta = LPAD(cuenta::text, 6, '0')) AS historico,
      (SELECT jsonb_agg(row_to_json(c)) 
       FROM public.comp_400 c 
       WHERE c.recaud = LPAD(recaud::text, 3, '0') 
         AND c.urbrus = ur 
         AND c.cuenta = LPAD(cuenta::text, 6, '0')) AS comp_400;
END;
$$ LANGUAGE plpgsql;

-- ============================================