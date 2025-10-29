-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: consAnun400frm
-- Generado: 2025-08-27 17:10:26
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_get_anuncio_400
-- Tipo: Report
-- Descripción: Obtiene todos los datos de un anuncio del AS/400 por número de anuncio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_anuncio_400(anuncio_in integer)
RETURNS TABLE (
    zona text, nzona text, nmza text, fecalt date, feccam date, fecbaj date,
    nuay1 text, cvpa1 text, fepa1 date, rein1 text, recl1 text, nuof1 text, impe1 numeric, imiv1 numeric, pdpa1 numeric, nuct1 text,
    nuay2 text, cvpa2 text, fepa2 date, rein2 text, recl2 text, nuof2 text, impe2 numeric, imiv2 numeric, pdpa2 numeric, nuct2 text,
    nuay3 text, cvpa3 text, fepa3 date, rein3 text, recl3 text, nuof3 text, impe3 numeric, imiv3 numeric, pdpa3 numeric, nuct3 text,
    nuayt3 text, reint3 text, rctl text, impet numeric, imivt numeric, cvemc text, fut1 text, fut2 text, numlica text, numanu integer,
    nomesta text, rfc text, numdili text, ngrupo text, lsector text, ncolon text, ncalle text, lcalle text, tipubic text, nubic text,
    nomcol text, nomcall text, noext text, lext text, nint text, lint text, nempre text, nomcau text, crfc text, cngrupo text, clsector text,
    cncolon text, cncalle text, clcalle text, ctipubic text, cnubic text, cnomcol text, cnomcall text, cnext text, clext text, cnint text,
    clint text, tipanu text, pmetr numeric, smetr numeric, angrupo text, alsector text, ancolon text, ancalle text, alcalle text, anubic text,
    anomcol text, anomcall text, anext text, alext text, anint text, alint text
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM anuncio_400 WHERE numanu = anuncio_in;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_get_pagos_anun_400
-- Tipo: Report
-- Descripción: Obtiene todos los pagos asociados a un anuncio del AS/400 por número de anuncio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagos_anun_400(numanu_in integer)
RETURNS SETOF pago_anun_400 AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pago_anun_400 WHERE numanu = numanu_in;
END;
$$ LANGUAGE plpgsql;

-- ============================================

