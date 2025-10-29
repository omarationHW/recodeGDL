-- Stored Procedure: sp_get_adeudos_by_cuenta
-- Tipo: Report
-- Descripción: Obtiene los adeudos de una cuenta catastral
-- Generado para formulario: CatastroDM
-- Fecha: 2025-08-27 21:03:36

CREATE OR REPLACE FUNCTION sp_get_adeudos_by_cuenta(p_cvecuenta INTEGER)
RETURNS TABLE(
    axosal INTEGER,
    bimsal INTEGER,
    impfac NUMERIC,
    recfac NUMERIC,
    saldo NUMERIC
) AS $$
BEGIN
    RETURN QUERY SELECT axosal, bimsal, impfac, recfac, saldo
    FROM detsaldos WHERE cvecuenta = p_cvecuenta ORDER BY axosal, bimsal;
END;
$$ LANGUAGE plpgsql;