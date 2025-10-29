-- Stored Procedure: sp_get_regimen_propiedad_historico
-- Tipo: Report
-- Descripción: Obtiene el régimen de propiedad histórico de la cuenta
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-26 17:34:10

CREATE OR REPLACE FUNCTION sp_get_regimen_propiedad_historico(p_cvecuenta INTEGER)
RETURNS TABLE(
    encabeza VARCHAR,
    porcentaje NUMERIC,
    descripcion VARCHAR,
    exento VARCHAR,
    ncompleto VARCHAR,
    rfc VARCHAR,
    calle VARCHAR,
    interior VARCHAR,
    noexterior VARCHAR,
    poblacion VARCHAR,
    municipio VARCHAR,
    estado VARCHAR,
    pais VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT encabeza, porcentaje, descripcion, exento, ncompleto, rfc, calle, interior, noexterior, poblacion, municipio, estado, pais
    FROM regprop
    WHERE cvecuenta = p_cvecuenta
    ORDER BY feccap DESC;
END;
$$ LANGUAGE plpgsql;