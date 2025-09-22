-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CTROL_IMP_CAT (EXACTO del archivo original)
-- Archivo: 71_SP_ASEO_CTROL_IMP_CAT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_ctrol_imp_cat_report
-- Tipo: Report
-- Descripción: Devuelve el catálogo de claves de operación ordenado según parámetro: 1-Control, 2-Clave, 3-Descripción.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ctrol_imp_cat_report(p_order integer)
RETURNS TABLE(ctrol_operacion integer, cve_operacion varchar, descripcion varchar)
LANGUAGE plpgsql AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT ctrol_operacion, cve_operacion, descripcion FROM public.ta_16_operacion ORDER BY %s',
    CASE p_order
      WHEN 1 THEN 'ctrol_operacion'
      WHEN 2 THEN 'cve_operacion'
      WHEN 3 THEN 'descripcion'
      ELSE 'ctrol_operacion'
    END
  );
END;
$$;

-- ============================================

