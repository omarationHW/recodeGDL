-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: MULTAS400FRM (EXACTO del archivo original)
-- Archivo: 103_SP_RECAUDADORA_MULTAS400FRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: multas_fed_400_search_by_acta
-- Tipo: Report
-- Descripción: Busca multas federales por dependencia, año y número de acta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION multas_fed_400_search_by_acta(
    p_depfed VARCHAR,
    p_axofed INTEGER,
    p_numacta INTEGER
)
RETURNS SETOF multas_fed_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_fed_400
    WHERE depfed = p_depfed
      AND axofed = p_axofed
      AND numacta = p_numacta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: MULTAS400FRM (EXACTO del archivo original)
-- Archivo: 103_SP_RECAUDADORA_MULTAS400FRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: multas_fed_400_search_by_domici
-- Tipo: Report
-- Descripción: Busca multas federales por domicilio (LIKE, mayúsculas).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION multas_fed_400_search_by_domici(
    p_domici VARCHAR
)
RETURNS SETOF multas_fed_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_fed_400
    WHERE UPPER(domici) LIKE UPPER(p_domici)
    ORDER BY domici;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: MULTAS400FRM (EXACTO del archivo original)
-- Archivo: 103_SP_RECAUDADORA_MULTAS400FRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: multas_mpal_400_search_by_nombre
-- Tipo: Report
-- Descripción: Busca multas municipales por nombre (LIKE, mayúsculas).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION multas_mpal_400_search_by_nombre(
    p_nombre VARCHAR
)
RETURNS SETOF multas_mpal_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_mpal_400
    WHERE UPPER(nombre) LIKE UPPER(p_nombre)
    ORDER BY nombre;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: MULTAS400FRM (EXACTO del archivo original)
-- Archivo: 103_SP_RECAUDADORA_MULTAS400FRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

