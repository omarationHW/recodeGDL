-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: reqmultas400frm
-- Generado: 2025-08-27 14:47:13
-- Total SPs: 2
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

-- SP 2/2: req_mul_400_by_folio
-- Tipo: Report
-- Descripción: Consulta requerimientos de multas 400 por año de requerimiento, folio y tipo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION req_mul_400_by_folio(
    axo INTEGER,
    folio INTEGER,
    tipo INTEGER
)
RETURNS SETOF req_mul_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM req_mul_400
    WHERE axoreq = axo
      AND folreq = folio
      AND cveapl = tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

