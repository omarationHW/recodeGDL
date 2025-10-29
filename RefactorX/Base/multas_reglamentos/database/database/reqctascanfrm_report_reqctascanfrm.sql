-- Stored Procedure: report_reqctascanfrm
-- Tipo: Report
-- Descripción: Obtiene la lista de cuentas canceladas para una recaudadora y rango de fechas.
-- Generado para formulario: reqctascanfrm
-- Fecha: 2025-08-27 14:30:35

CREATE OR REPLACE FUNCTION report_reqctascanfrm(
    p_recaud integer,
    p_fini date,
    p_ffin date
)
RETURNS TABLE (
    cvecuenta integer,
    recaud smallint,
    cuenta integer,
    cuenta_utm text
) AS $$
BEGIN
    RETURN QUERY
    SELECT c1.cvecuenta, c1.recaud, c1.cuenta,
           (c1.recaud::text || '-' || c1.urbrus::text || '-' || c1.cuenta::text) AS cuenta_utm
    FROM convcta c1
    JOIN catastro ct ON c1.cvecuenta = ct.cvecuenta
    JOIN reqpredial r ON r.cvecuenta = c1.cvecuenta
    WHERE c1.recaud = p_recaud
      AND ct.cvemov = 11
      AND ct.feccap BETWEEN p_fini AND p_ffin
      AND r.vigencia = 'V'
    GROUP BY c1.cvecuenta, c1.recaud, c1.cuenta, c1.urbrus
    ORDER BY c1.recaud, c1.cuenta;
END;
$$ LANGUAGE plpgsql;