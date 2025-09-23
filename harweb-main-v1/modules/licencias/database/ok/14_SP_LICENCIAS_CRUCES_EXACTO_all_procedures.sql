-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CRUCES (EXACTO del archivo original)
-- Archivo: 14_SP_LICENCIAS_CRUCES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_cruces_search_calle1
-- Tipo: Catalog
-- Descripción: Busca calles para el primer campo de cruce, excluyendo las escondidas y filtrando por nombre.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cruces_search_calle1(search_text TEXT)
RETURNS TABLE (
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
    FROM c_calles
    WHERE UPPER(calle) LIKE '%' || UPPER(search_text) || '%'
      AND cvecalle NOT IN (
        SELECT cvecalle FROM c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000
      );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: CRUCES (EXACTO del archivo original)
-- Archivo: 14_SP_LICENCIAS_CRUCES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_cruces_localiza_calle
-- Tipo: CRUD
-- Descripción: Localiza los datos completos de dos calles por sus claves (puede ser una o ambas). Devuelve tipo=1 para calle1 y tipo=2 para calle2.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cruces_localiza_calle(cvecalle1 INTEGER, cvecalle2 INTEGER)
RETURNS TABLE (
    tipo INTEGER,
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig CHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    IF cvecalle1 > 0 THEN
        RETURN QUERY
        SELECT 1 AS tipo, cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
        FROM c_calles WHERE cvecalle = cvecalle1;
    END IF;
    IF cvecalle2 > 0 THEN
        RETURN QUERY
        SELECT 2 AS tipo, cvecalle, cvepoblacion, desvial, calle, cvevig, anterior, feccap, capturista
        FROM c_calles WHERE cvecalle = cvecalle2;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

