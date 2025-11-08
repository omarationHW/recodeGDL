-- Stored Procedure: sp_get_diferencias_historico
-- Tipo: Report
-- Descripción: Obtiene diferencias históricas de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:10

CREATE OR REPLACE FUNCTION sp_get_diferencias_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    bimini INTEGER,
    axoini INTEGER,
    bimfin INTEGER,
    axofin INTEGER,
    tasaant NUMERIC,
    stasaant NUMERIC,
    valfisant NUMERIC,
    tasa NUMERIC,
    axosobretasa NUMERIC,
    valfiscal NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT bimini, axoini, bimfin, axofin, tasaant, stasaant, valfisant, tasa, axosobretasa, valfiscal
    FROM valmodif
    WHERE cvecuenta = p_cvecuenta
    ORDER BY axoini DESC, bimini DESC;
END;
$$ LANGUAGE plpgsql;