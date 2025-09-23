-- Stored Procedure: sp_buscar_cuenta_catastral
-- Tipo: Catalog
-- Descripción: Busca cuenta catastral por recaudadora, urbrus y cuenta
-- Generado para formulario: SGCv2
-- Fecha: 2025-08-27 19:38:17

CREATE OR REPLACE FUNCTION sp_buscar_cuenta_catastral(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    cuenta INTEGER,
    cvecatnva VARCHAR,
    subpredio INTEGER,
    claveutm VARCHAR,
    manzana VARCHAR,
    ctacat VARCHAR,
    vigente VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, recaud, urbrus, cuenta, cvecatnva, subpredio,
           (recaud || '-' || urbrus || '-' || cuenta) AS claveutm,
           (cip || subpredio) AS manzana,
           (cvecatnva || subpredio) AS ctacat,
           vigente
    FROM convcta
    WHERE recaud = p_recaud AND urbrus = p_urbrus AND cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;