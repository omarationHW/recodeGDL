-- Stored Procedure: sp_get_hist_uem
-- Tipo: Report
-- Descripción: Obtiene el histórico UEM de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:10

CREATE OR REPLACE FUNCTION sp_get_hist_uem(p_cvecuenta INTEGER)
RETURNS TABLE(
    zona INTEGER,
    calleu VARCHAR,
    prop VARCHAR,
    called VARCHAR,
    pobld VARCHAR,
    areaterr NUMERIC,
    valterr NUMERIC,
    valfis NUMERIC,
    ultacomp INTEGER,
    areaconst NUMERIC,
    valconst NUMERIC,
    tasauem NUMERIC,
    efec INTEGER,
    homorfc VARCHAR,
    numrfc INTEGER,
    extu VARCHAR,
    intu VARCHAR,
    extd VARCHAR,
    intd VARCHAR,
    cvecatnva VARCHAR,
    ccta INTEGER,
    capturo VARCHAR,
    exe VARCHAR,
    fut1 VARCHAR,
    fut2 VARCHAR,
    fut3 VARCHAR,
    fut4 VARCHAR,
    movimiento VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT zona, calleu, prop, called, pobld, areaterr, valterr, valfis, ultacomp, areaconst, valconst, tasauem, efec, homorfc, numrfc, extu, intu, extd, intd, cvecatnva, ccta, capturo, exe, fut1, fut2, fut3, fut4, movimiento
    FROM historico_uem
    WHERE cvecuenta = p_cvecuenta
    ORDER BY ultacomp DESC;
END;
$$ LANGUAGE plpgsql;