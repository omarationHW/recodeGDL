-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sfrmprediocarto
-- Generado: 2025-08-27 14:04:09
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_get_predio_carto_url
-- Tipo: CRUD
-- Descripción: Devuelve la URL del visor cartográfico para una clave catastral dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_predio_carto_url(p_cvecatastro TEXT)
RETURNS TEXT AS $$
DECLARE
    v_url TEXT;
BEGIN
    IF p_cvecatastro IS NULL OR LENGTH(TRIM(p_cvecatastro)) = 0 THEN
        RAISE EXCEPTION 'Clave catastral requerida';
    END IF;
    v_url := 'http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=' || p_cvecatastro;
    RETURN v_url;
END;
$$ LANGUAGE plpgsql;

-- ============================================

