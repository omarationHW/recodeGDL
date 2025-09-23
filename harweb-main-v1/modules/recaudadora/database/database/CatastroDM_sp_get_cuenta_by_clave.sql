-- Stored Procedure: sp_get_cuenta_by_clave
-- Tipo: Catalog
-- Descripción: Obtiene la cuenta catastral por clave catastral
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-27 21:03:36

CREATE OR REPLACE FUNCTION sp_get_cuenta_by_clave(p_clave TEXT)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva TEXT,
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY SELECT cvecuenta, cvecatnva, recaud, urbrus, cuenta
    FROM convcta WHERE cvecatnva = p_clave;
END;
$$ LANGUAGE plpgsql;