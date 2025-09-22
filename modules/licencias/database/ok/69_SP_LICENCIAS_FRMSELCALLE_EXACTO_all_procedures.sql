-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FRMSELCALLE (EXACTO del archivo original)
-- Archivo: 69_SP_LICENCIAS_FRMSELCALLE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_get_calles
-- Tipo: Catalog
-- Descripción: Obtiene todas las calles o filtra por nombre usando prefijo (como 'matches' en Delphi).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_calles(filter TEXT DEFAULT '')
RETURNS TABLE (cvecalle INTEGER, calle TEXT) AS $$
BEGIN
    IF filter IS NULL OR trim(filter) = '' THEN
        RETURN QUERY SELECT cvecalle, calle FROM c_calles ORDER BY calle;
    ELSE
        RETURN QUERY SELECT cvecalle, calle FROM c_calles WHERE calle ILIKE filter || '%' ORDER BY calle;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FRMSELCALLE (EXACTO del archivo original)
-- Archivo: 69_SP_LICENCIAS_FRMSELCALLE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

