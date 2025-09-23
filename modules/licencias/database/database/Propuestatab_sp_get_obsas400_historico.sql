-- Stored Procedure: sp_get_obsas400_historico
-- Tipo: Report
-- Descripción: Obtiene observaciones AS-400 históricas de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:10

CREATE OR REPLACE FUNCTION sp_get_obsas400_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    acomp INTEGER,
    observa TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT acomp, observa
    FROM observ_400
    WHERE cvecuenta = p_cvecuenta
    ORDER BY acomp DESC;
END;
$$ LANGUAGE plpgsql;