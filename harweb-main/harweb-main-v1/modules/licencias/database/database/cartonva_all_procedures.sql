-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: cartonva
-- Generado: 2025-08-27 16:43:36
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_cartografia_predial
-- Tipo: CRUD
-- Descripción: Obtiene la información de la cuenta catastral y la URL del visor cartográfico
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cartografia_predial(p_cvecuenta INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION,
    visor_url TEXT
) AS $$
DECLARE
    v_cvecatnva VARCHAR(11);
    v_url TEXT;
BEGIN
    SELECT * INTO STRICT cvecuenta, cvemunicipio, recaud, urbrus, cuenta, digver, zonaanter, manzanter, loteanter, cvecatnva, subpredio, crec, cur, ccta, cip, vigente, cvelocalidad, coordenada_x, coordenada_y
    FROM convcta WHERE cvecuenta = p_cvecuenta;
    v_cvecatnva := cvecatnva;
    v_url := 'http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=' || v_cvecatnva;
    visor_url := v_url;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_cuenta_by_cvecuenta
-- Tipo: Catalog
-- Descripción: Obtiene la información de la cuenta catastral por cvecuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cuenta_by_cvecuenta(p_cvecuenta INTEGER)
RETURNS TABLE (
    cvecuenta INTEGER,
    cvemunicipio SMALLINT,
    recaud SMALLINT,
    urbrus VARCHAR(1),
    cuenta INTEGER,
    digver SMALLINT,
    zonaanter SMALLINT,
    manzanter SMALLINT,
    loteanter SMALLINT,
    cvecatnva VARCHAR(11),
    subpredio SMALLINT,
    crec SMALLINT,
    cur VARCHAR(1),
    ccta INTEGER,
    cip VARCHAR(9),
    vigente VARCHAR(1),
    cvelocalidad SMALLINT,
    coordenada_x DOUBLE PRECISION,
    coordenada_y DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY SELECT cvecuenta, cvemunicipio, recaud, urbrus, cuenta, digver, zonaanter, manzanter, loteanter, cvecatnva, subpredio, crec, cur, ccta, cip, vigente, cvelocalidad, coordenada_x, coordenada_y
    FROM convcta WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================

