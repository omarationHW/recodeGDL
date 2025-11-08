-- Stored Procedure: sp_get_valores_historico
-- Tipo: Report
-- Descripción: Obtiene los valores históricos de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:10

CREATE OR REPLACE FUNCTION sp_get_valores_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    areaterr NUMERIC,
    areaconst NUMERIC,
    valterr NUMERIC,
    valconst NUMERIC,
    valfiscal NUMERIC,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT areaterr, areaconst, valterr, valconst, valfiscal, feccap
    FROM valores
    WHERE cvecuenta = p_cvecuenta
    ORDER BY feccap DESC;
END;
$$ LANGUAGE plpgsql;