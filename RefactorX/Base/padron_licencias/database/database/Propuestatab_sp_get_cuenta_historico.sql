-- Stored Procedure: sp_get_cuenta_historico
-- Tipo: Report
-- Descripción: Obtiene el histórico de la cuenta catastral principal
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:09

CREATE OR REPLACE FUNCTION sp_get_cuenta_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    urbrus VARCHAR,
    cuenta INTEGER,
    cvecatnva VARCHAR,
    subpredio INTEGER,
    crec INTEGER,
    cur VARCHAR,
    ccta INTEGER,
    cmovto VARCHAR,
    indiviso NUMERIC,
    tasa NUMERIC,
    observacion TEXT,
    axocomp INTEGER,
    nocomp INTEGER,
    asiento INTEGER,
    axoultcomp INTEGER,
    ultcomp INTEGER,
    feccap DATE,
    capturista VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, urbrus, cuenta, cvecatnva, subpredio, crec, cur, ccta, cmovto, indiviso, tasa, observacion, axocomp, nocomp, asiento, axoultcomp, ultcomp, feccap, capturista
    FROM historico
    WHERE cvecuenta = p_cvecuenta
    ORDER BY feccap DESC;
END;
$$ LANGUAGE plpgsql;