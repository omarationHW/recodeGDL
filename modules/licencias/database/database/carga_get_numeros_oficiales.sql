-- Stored Procedure: get_numeros_oficiales
-- Tipo: Report
-- Descripción: Devuelve los números oficiales de una manzana.
-- Generado para formulario: carga
-- Fecha: 2025-08-27 16:36:45

CREATE OR REPLACE FUNCTION get_numeros_oficiales(p_cvemanz VARCHAR)
RETURNS TABLE(
    cvecatnva VARCHAR,
    num VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.cvecatnva, CASE WHEN a.interior = '00000' OR a.interior = '' THEN a.noexterior ELSE a.noexterior || '-' || a.interior END AS num
    FROM ubicacion a
    JOIN convcta b ON b.cvecatnva LIKE p_cvemanz || '%' AND b.vigente = 'V'
    WHERE a.cvecuenta = b.cvecuenta AND a.vigencia = 'V';
END;
$$ LANGUAGE plpgsql;