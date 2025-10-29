-- Stored Procedure: pagosmultfrm_get_pagoscan
-- Tipo: Report
-- Descripción: Obtiene los registros de pagos cancelados para un pago específico.
-- Generado para formulario: pagosmultfrm
-- Fecha: 2025-08-27 14:09:11

CREATE OR REPLACE FUNCTION pagosmultfrm_get_pagoscan(
    p_cvepago INTEGER
)
RETURNS TABLE (
    cvecanc INTEGER,
    cvepago INTEGER,
    autorizo TEXT,
    fechacan DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecanc, cvepago, autorizo, fechacan
    FROM pagoscan
    WHERE cvepago = p_cvepago;
END;
$$ LANGUAGE plpgsql;