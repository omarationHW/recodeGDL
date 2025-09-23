-- Stored Procedure: sp_busque_get_detail
-- Tipo: Report
-- Descripción: Obtiene el detalle completo de una cuenta catastral por recaud, urbrus y cuenta.
-- Generado para formulario: busque
-- Fecha: 2025-08-27 16:29:20

CREATE OR REPLACE FUNCTION sp_busque_get_detail(p_recaud TEXT, p_urbrus TEXT, p_cuenta TEXT)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva TEXT,
    subpredio SMALLINT,
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    vigente TEXT,
    detalle JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecuenta, c.cvecatnva, c.subpredio, c.recaud, c.urbrus, c.cuenta, c.vigente,
           to_jsonb(row_to_json(c))
    FROM convcta c
    WHERE c.recaud = p_recaud::SMALLINT
      AND c.urbrus = p_urbrus
      AND c.cuenta = p_cuenta::INTEGER
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;