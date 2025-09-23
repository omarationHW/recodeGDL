-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: consLic400frm
-- Generado: 2025-08-27 17:12:15
-- Total SPs: 2
-- ============================================

-- SP 1/2: get_lic_400
-- Tipo: Catalog
-- Descripción: Obtiene los datos de una licencia 400 por número de licencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_lic_400(p_licencia INTEGER)
RETURNS TABLE (
    ofna TEXT,
    numlic INTEGER,
    inirfc TEXT,
    fnarfc TEXT,
    homono TEXT,
    dighom TEXT,
    codgir TEXT,
    ilgir1 TEXT,
    ilgir2 TEXT,
    ilgir3 TEXT,
    nocars TEXT,
    nugrub TEXT,
    nuext TEXT,
    letext TEXT,
    numint TEXT,
    letint TEXT,
    piso TEXT,
    letsec TEXT,
    numzon TEXT,
    zonpos TEXT,
    fecalt DATE,
    fecbaj DATE,
    nomcal TEXT,
    tomesu TEXT,
    numanu TEXT,
    nuayt TEXT,
    reint TEXT,
    reclt TEXT,
    imlit NUMERIC,
    liimt NUMERIC,
    vigenc TEXT,
    actgrl TEXT,
    grabo TEXT,
    resta TEXT,
    fut1 TEXT,
    fut2 TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ofna, numlic, inirfc, fnarfc, homono, dighom, codgir, ilgir1, ilgir2, ilgir3, nocars, nugrub, nuext, letext, numint, letint, piso, letsec, numzon, zonpos, fecalt, fecbaj, nomcal, tomesu, numanu, nuayt, reint, reclt, imlit, liimt, vigenc, actgrl, grabo, resta, fut1, fut2
    FROM lic_400
    WHERE numlic = p_licencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: get_pago_lic_400
-- Tipo: Catalog
-- Descripción: Obtiene los pagos asociados a una licencia 400.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_pago_lic_400(p_numlic INTEGER)
RETURNS SETOF pago_lic_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pago_lic_400 WHERE numlic = p_numlic;
END;
$$ LANGUAGE plpgsql;

-- ============================================

