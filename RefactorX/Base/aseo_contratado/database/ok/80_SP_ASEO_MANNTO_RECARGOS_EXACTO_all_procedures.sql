-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_RECARGOS (EXACTO del archivo original)
-- Archivo: 80_SP_ASEO_MANNTO_RECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos de un año dado
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_list(p_year INTEGER)
RETURNS TABLE(ano_mes TEXT, ano INTEGER, mes INTEGER, porc_recargo NUMERIC, porc_multa NUMERIC) AS $$
BEGIN
  RETURN QUERY
    SELECT TO_CHAR(aso_mes_recargo, 'YYYY-MM') AS ano_mes,
           EXTRACT(YEAR FROM aso_mes_recargo)::INTEGER AS ano,
           EXTRACT(MONTH FROM aso_mes_recargo)::INTEGER AS mes,
           porc_recargo, porc_multa
      FROM public.ta_16_recargos
     WHERE EXTRACT(YEAR FROM aso_mes_recargo) = p_year
     ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_RECARGOS (EXACTO del archivo original)
-- Archivo: 80_SP_ASEO_MANNTO_RECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_recargos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de recargo existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_update(p_year INTEGER, p_month INTEGER, p_porc_recargo NUMERIC, p_porc_multa NUMERIC)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_date DATE := TO_DATE(p_year::TEXT || '-' || LPAD(p_month::TEXT,2,'0') || '-01', 'YYYY-MM-DD');
  v_exists INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM public.ta_16_recargos WHERE aso_mes_recargo = v_date;
  IF v_exists = 0 THEN
    RETURN QUERY SELECT FALSE, 'No existe recargo para ese periodo';
    RETURN;
  END IF;
  UPDATE public.ta_16_recargos
     SET porc_recargo = p_porc_recargo,
         porc_multa = p_porc_multa
   WHERE aso_mes_recargo = v_date;
  RETURN QUERY SELECT TRUE, 'Recargo actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_RECARGOS (EXACTO del archivo original)
-- Archivo: 80_SP_ASEO_MANNTO_RECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

