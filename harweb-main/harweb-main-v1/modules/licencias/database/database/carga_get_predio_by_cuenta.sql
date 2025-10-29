-- Stored Procedure: get_predio_by_cuenta
-- Tipo: CRUD
-- Descripción: Obtiene los datos completos del predio por cuenta (recaud, urbrus, cuenta).
-- Generado para formulario: carga
-- Fecha: 2025-08-27 16:36:45

CREATE OR REPLACE FUNCTION get_predio_by_cuenta(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
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
    WHERE c.recaud = p_recaud AND c.urbrus = p_urbrus AND c.cuenta = p_cuenta AND c.vigente = 'V';
END;
$$ LANGUAGE plpgsql;