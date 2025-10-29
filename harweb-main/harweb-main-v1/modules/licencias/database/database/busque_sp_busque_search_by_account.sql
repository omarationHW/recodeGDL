-- Stored Procedure: sp_busque_search_by_account
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por recaudadora, urbrus y cuenta.
-- Generado para formulario: busque
-- Fecha: 2025-08-27 16:29:20

CREATE OR REPLACE FUNCTION sp_busque_search_by_account(p_recaud TEXT, p_urbrus TEXT, p_cuenta TEXT)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva TEXT,
    subpredio SMALLINT,
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    vigente TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecuenta, cvecatnva, subpredio, recaud, urbrus, cuenta, vigente
    FROM convcta
    WHERE recaud = p_recaud::SMALLINT
      AND urbrus = p_urbrus
      AND cuenta = p_cuenta::INTEGER
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;