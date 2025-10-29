-- Stored Procedure: report_reqctascanfrm_folios
-- Tipo: Report
-- Descripción: Obtiene los folios de requerimiento para una cuenta específica que no han sido cancelados y están vigentes.
-- Generado para formulario: reqctascanfrm
-- Fecha: 2025-08-27 14:30:35

CREATE OR REPLACE FUNCTION report_reqctascanfrm_folios(
    p_cvecuenta integer
)
RETURNS TABLE (
    folioreq integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT folioreq
    FROM reqpredial
    WHERE cvecuenta = p_cvecuenta
      AND feccan IS NULL
      AND vigencia = 'V'
    ORDER BY folioreq;
END;
$$ LANGUAGE plpgsql;