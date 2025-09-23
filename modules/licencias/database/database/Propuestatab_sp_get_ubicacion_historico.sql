-- Stored Procedure: sp_get_ubicacion_historico
-- Tipo: Report
-- Descripción: Obtiene el histórico de ubicación de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:10

CREATE OR REPLACE FUNCTION sp_get_ubicacion_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    calle VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    colonia VARCHAR,
    vigencia VARCHAR,
    obsinter TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT calle, noexterior, interior, colonia, vigencia, obsinter
    FROM ubicacion
    WHERE cvecuenta = p_cvecuenta
    ORDER BY feccap DESC;
END;
$$ LANGUAGE plpgsql;