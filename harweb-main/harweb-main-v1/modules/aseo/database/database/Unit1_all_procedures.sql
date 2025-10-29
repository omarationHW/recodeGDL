-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Unit1
-- Generado: 2025-08-27 15:46:55
-- Total SPs: 1
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

