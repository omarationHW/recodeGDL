-- Stored Procedure: sp_busqueda_por_ubicacion
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por calle y número exterior.
-- Generado para formulario: busque
-- Fecha: 2025-08-27 20:41:21

CREATE OR REPLACE FUNCTION sp_busqueda_por_ubicacion(p_calle TEXT, p_exterior TEXT)
RETURNS TABLE(
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    cvecuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT calle, noexterior, interior, cvecuenta
    FROM ubicacion
    WHERE calle ILIKE '%' || p_calle || '%'
      AND (p_exterior = '' OR noexterior ILIKE '%' || p_exterior || '%')
      AND vigencia = 'V'
    ORDER BY calle, noexterior
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;