-- Stored Procedure: sp_listado_ubicodifica
-- Tipo: Report
-- Descripción: Listado de cuentas sin zona/subzona.
-- Generado para formulario: Ubicodifica
-- Fecha: 2025-08-27 15:58:02

CREATE OR REPLACE FUNCTION sp_listado_ubicodifica(p_reca INTEGER, p_ctaini INTEGER, p_ctafin INTEGER)
RETURNS TABLE(
    recaud INTEGER,
    urbrus TEXT,
    cuenta INTEGER,
    cvecatnva TEXT,
    calle TEXT,
    noexterior TEXT,
    interior TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.recaud, c.urbrus, c.cuenta, c.cvecatnva, u.calle, u.noexterior, u.interior
    FROM convcta c
    JOIN catastro ct ON ct.cvecuenta = c.cvecuenta
    JOIN ubicacion u ON u.cveubic = ct.cveubic
    WHERE c.recaud = p_reca
      AND c.cuenta BETWEEN p_ctaini AND p_ctafin
      AND (substring(c.cip from 1 for 3) = '   ' OR c.cip IS NULL OR substring(c.cip from 1 for 1) = '0')
    ORDER BY c.recaud, c.cuenta;
END;
$$ LANGUAGE plpgsql;