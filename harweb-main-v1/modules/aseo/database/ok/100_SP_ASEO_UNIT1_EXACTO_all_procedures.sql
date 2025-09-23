-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: UNIT1 (EXACTO del archivo original)
-- Archivo: 100_SP_ASEO_UNIT1_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_unit1_get_form_data
-- Tipo: Catalog
-- Descripción: Devuelve información básica del formulario Unit1 (sin datos, ya que el formulario está vacío).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unit1_get_form_data()
RETURNS TABLE(status text, message text) AS $$
BEGIN
    RETURN QUERY SELECT 'OK'::text, 'Formulario Unit1 cargado correctamente.'::text;
END;
$$ LANGUAGE plpgsql;

-- ============================================

