-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FORMABUSCALLE (EXACTO del archivo original)
-- Archivo: 65_SP_LICENCIAS_FORMABUSCALLE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_buscar_calles
-- Tipo: Catalog
-- Descripción: Busca calles cuyo nombre contenga el filtro, excluyendo las ocultas (vigente = 'V' y num_tag = 8000).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_buscar_calles(filtro TEXT)
RETURNS TABLE (
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig VARCHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
    FROM c_calles
    WHERE calle ILIKE '%' || filtro || '%'
      AND cvecalle NOT IN (
        SELECT cvecalle FROM c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: FORMABUSCALLE (EXACTO del archivo original)
-- Archivo: 65_SP_LICENCIAS_FORMABUSCALLE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

