-- Stored Procedure: sp_get_lic_400
-- Tipo: Catalog
-- Descripción: Obtiene los datos de una licencia específica de la tabla lic_400.
-- Generado para formulario: consLic400frm
-- Fecha: 2025-08-26 15:34:48

CREATE OR REPLACE FUNCTION sp_get_lic_400(p_licencia INTEGER)
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
    nomcal TEXT,
    letext TEXT,
    numint TEXT,
    letint TEXT,
    piso TEXT,
    letsec TEXT,
    numzon TEXT,
    zonpos TEXT,
    fecalt DATE,
    fecbaj DATE,
    tomesu TEXT,
    numanu TEXT,
    nuayt TEXT,
    reint TEXT,
    reclt TEXT,
    imlit TEXT,
    liimt TEXT,
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
        ofna, numlic, inirfc, fnarfc, homono, dighom, codgir, ilgir1, ilgir2, ilgir3, nocars, nugrub, nuext, nomcal, letext, numint, letint, piso, letsec, numzon, zonpos, fecalt, fecbaj, tomesu, numanu, nuayt, reint, reclt, imlit, liimt, vigenc, actgrl, grabo, resta, fut1, fut2
    FROM lic_400
    WHERE numlic = p_licencia;
END;
$$ LANGUAGE plpgsql;