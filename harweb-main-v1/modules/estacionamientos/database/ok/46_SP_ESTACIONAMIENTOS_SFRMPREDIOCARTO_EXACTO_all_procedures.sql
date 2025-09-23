-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ESTACIONAMIENTOS
-- Formulario: SFRMPREDIOCARTO (EXACTO del archivo original)
-- Archivo: 46_SP_ESTACIONAMIENTOS_SFRMPREDIOCARTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
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

