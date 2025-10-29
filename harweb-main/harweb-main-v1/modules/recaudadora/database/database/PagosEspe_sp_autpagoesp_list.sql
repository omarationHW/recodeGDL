-- Stored Procedure: sp_autpagoesp_list
-- Tipo: Report
-- Descripción: Lista los pagos especiales autorizados para una cuenta
-- Generado para formulario: PagosEspe
-- Fecha: 2025-08-27 14:06:05

CREATE OR REPLACE FUNCTION sp_autpagoesp_list(p_cvecuenta integer)
RETURNS TABLE(
    cveaut integer,
    bimini smallint,
    axoini smallint,
    bimfin smallint,
    axofin smallint,
    fecaut date,
    autorizo varchar,
    cvecuenta integer,
    cvepago integer
) AS $$
BEGIN
    RETURN QUERY SELECT cveaut, bimini, axoini, bimfin, axofin, fecaut, autorizo, cvecuenta, cvepago
    FROM autpagoesp WHERE cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;