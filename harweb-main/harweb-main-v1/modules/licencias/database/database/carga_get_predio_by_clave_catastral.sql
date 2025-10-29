-- Stored Procedure: get_predio_by_clave_catastral
-- Tipo: CRUD
-- Descripción: Obtiene los datos completos del predio por clave catastral y subpredio.
-- Generado para formulario: carga
-- Fecha: 2025-08-27 16:36:45

CREATE OR REPLACE FUNCTION get_predio_by_clave_catastral(p_cvecatnva VARCHAR, p_subpredio INTEGER)
RETURNS TABLE(
    cvecatnva VARCHAR,
    subpredio INTEGER,
    cuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    propietario VARCHAR,
    ubicacion VARCHAR,
    colonia VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecatnva, c.subpredio, c.cuenta, c.recaud, c.urbrus, p.nombre_completo AS propietario,
           u.calle AS ubicacion, u.colonia, u.noexterior, u.interior, a.supterr, a.supconst, a.valorterr, a.valorconst, a.valfiscal
    FROM convcta c
    LEFT JOIN catastro a ON a.cvecuenta = c.cvecuenta
    LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
    LEFT JOIN (
        SELECT cvecuenta, MAX(CONCAT(paterno, ' ', materno, ' ', nombres)) AS nombre_completo
        FROM contrib
        GROUP BY cvecuenta
    ) p ON p.cvecuenta = c.cvecuenta
    WHERE c.cvecatnva = p_cvecatnva AND c.subpredio = p_subpredio AND c.vigente = 'V';
END;
$$ LANGUAGE plpgsql;