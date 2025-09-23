-- Stored Procedure: carga_load_predio
-- Tipo: CRUD
-- Descripción: Carga los datos completos de un predio por cuenta catastral.
-- Generado para formulario: carga
-- Fecha: 2025-08-26 15:04:18

CREATE OR REPLACE FUNCTION carga_load_predio(p_cvecuenta INTEGER)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva VARCHAR,
    subpredio INTEGER,
    ubicacion VARCHAR,
    propietario VARCHAR,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC,
    colonia VARCHAR,
    rfc VARCHAR,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecuenta, c.cvecatnva, c.subpredio, u.ubicacion, p.propietario, a.supterr, a.supconst, a.valorterr, a.valorconst, a.valfiscal, u.colonia, p.rfc, a.feccap
    FROM convcta c
    LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
    LEFT JOIN propietario p ON p.cvecuenta = c.cvecuenta
    LEFT JOIN avaluos a ON a.cvecuenta = c.cvecuenta
    WHERE c.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;