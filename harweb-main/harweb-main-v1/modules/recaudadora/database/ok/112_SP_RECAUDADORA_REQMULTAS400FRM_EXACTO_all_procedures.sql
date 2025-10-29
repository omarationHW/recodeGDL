-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: REQMULTAS400FRM (EXACTO del archivo original)
-- Archivo: 112_SP_RECAUDADORA_REQMULTAS400FRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: req_mul_400_by_acta
-- Tipo: Report
-- Descripción: Consulta requerimientos de multas 400 por dependencia, año de acta, número de acta y tipo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION req_mul_400_by_acta(
    dep VARCHAR,
    axo INTEGER,
    numacta INTEGER,
    tipo INTEGER
)
RETURNS SETOF req_mul_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM req_mul_400
    WHERE SUBSTRING(cvelet FROM 4 FOR 3) = dep
      AND cvenum = axo
      AND ctarfc = numacta
      AND cveapl = tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: REQMULTAS400FRM (EXACTO del archivo original)
-- Archivo: 112_SP_RECAUDADORA_REQMULTAS400FRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

