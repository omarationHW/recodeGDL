-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: IMPRESIONNVA (EXACTO del archivo original)
-- Archivo: 59_SP_RECAUDADORA_IMPRESIONNVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_impresionnva_get_form_data
-- Tipo: CRUD
-- Descripción: Devuelve los datos necesarios para inicializar el formulario ImpresionNva (en este caso, vacío).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_impresionnva_get_form_data()
RETURNS JSON AS $$
BEGIN
    RETURN '{}'::json;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: IMPRESIONNVA (EXACTO del archivo original)
-- Archivo: 59_SP_RECAUDADORA_IMPRESIONNVA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

