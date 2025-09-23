-- Stored Procedure: sp_get_escrituras_historico
-- Tipo: Report
-- Descripción: Obtiene escrituras históricas de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:10

CREATE OR REPLACE FUNCTION sp_get_escrituras_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    escritura INTEGER,
    notario INTEGER,
    mpio INTEGER,
    folio INTEGER,
    axofolio INTEGER,
    nocomp INTEGER,
    axocomp INTEGER,
    ccta INTEGER,
    crec INTEGER,
    clave VARCHAR,
    capturista VARCHAR,
    enviado VARCHAR,
    regresado VARCHAR,
    fecha INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT escritura, notario, mpio, folio, axofolio, nocomp, axocomp, ccta, crec, clave, capturista, enviado, regresado, fecha
    FROM escrituras_400
    WHERE cvecuenta = p_cvecuenta
    ORDER BY escritura DESC;
END;
$$ LANGUAGE plpgsql;