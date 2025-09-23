-- Stored Procedure: sp_get_tot_pagado_by_predio
-- Tipo: Report
-- Descripción: Obtiene el total pagado por un predio/convenio
-- Generado para formulario: IndividualPredios
-- Fecha: 2025-08-27 14:45:56

CREATE OR REPLACE FUNCTION sp_get_tot_pagado_by_predio(p_id_conv_resto INTEGER)
RETURNS TABLE (
    importe_pago NUMERIC,
    cve_descuento SMALLINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT importe_pago, cve_descuento
    FROM ta_17_conv_pagos
    WHERE id_conv_resto = p_id_conv_resto
      AND cve_bonificacion IS NULL;
END;
$$ LANGUAGE plpgsql;