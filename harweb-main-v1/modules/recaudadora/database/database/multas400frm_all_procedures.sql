-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: multas400frm
-- Generado: 2025-08-27 13:11:21
-- Total SPs: 6
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

-- SP 2/6: multas_fed_400_search_by_nombre
-- Tipo: Report
-- Descripción: Busca multas federales por nombre (LIKE, mayúsculas).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION multas_fed_400_search_by_nombre(
    p_nombre VARCHAR
)
RETURNS SETOF multas_fed_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_fed_400
    WHERE UPPER(nombre) LIKE UPPER(p_nombre)
    ORDER BY nombre;
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/6: multas_mpal_400_search_by_acta
-- Tipo: Report
-- Descripción: Busca multas municipales por dependencia, año y número de acta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION multas_mpal_400_search_by_acta(
    p_depen VARCHAR,
    p_axoacta INTEGER,
    p_numacta INTEGER
)
RETURNS SETOF multas_mpal_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_mpal_400
    WHERE depen = p_depen
      AND axoacta = p_axoacta
      AND numacta = p_numacta;
END;
$$ LANGUAGE plpgsql;

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

-- SP 6/6: multas_mpal_400_search_by_domici
-- Tipo: Report
-- Descripción: Busca multas municipales por domicilio (LIKE, mayúsculas).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION multas_mpal_400_search_by_domici(
    p_domici VARCHAR
)
RETURNS SETOF multas_mpal_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM multas_mpal_400
    WHERE UPPER(domici) LIKE UPPER(p_domici)
    ORDER BY domici;
END;
$$ LANGUAGE plpgsql;

-- ============================================

