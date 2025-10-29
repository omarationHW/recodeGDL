-- Stored Procedure: sp_prepago_get_ultimo_requerimiento
-- Tipo: Catalog
-- Descripción: Obtiene el último requerimiento practicado para la cuenta.
-- Generado para formulario: prepagofrm
-- Fecha: 2025-08-27 18:51:25

CREATE OR REPLACE FUNCTION sp_prepago_get_ultimo_requerimiento(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvereq INTEGER,
    cveejecut SMALLINT,
    folioreq INTEGER,
    axoreq SMALLINT,
    cvecuenta INTEGER,
    cvepago INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    multas NUMERIC,
    total NUMERIC,
    fecemi DATE,
    fecent DATE,
    cvecancr TEXT,
    axoini SMALLINT,
    bimini SMALLINT,
    axofin SMALLINT,
    bimfin SMALLINT,
    secuencia SMALLINT,
    vigencia TEXT,
    feccap DATE,
    capturista TEXT,
    iniper TEXT,
    finper TEXT,
    diastrans INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT *, bimini::TEXT||'/'||axoini AS iniper, bimfin::TEXT||'/'||axofin AS finper, (CURRENT_DATE - fecent) AS diastrans
    FROM reqpredial
    WHERE cvecuenta = p_cvecuenta AND vigencia = 'V' AND fecent IS NOT NULL
    ORDER BY axoreq DESC, folioreq DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;