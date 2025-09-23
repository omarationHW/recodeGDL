-- Stored Procedure: sp_get_pagos_summary
-- Tipo: Report
-- Descripción: Resumen de pagos: cuenta y suma importe por ctrol_aseo, fecha, operación y status_vigencia.
-- Generado para formulario: uDM_Procesos
-- Fecha: 2025-08-27 15:45:14

CREATE OR REPLACE FUNCTION sp_get_pagos_summary(
    ctrol_a integer,
    fecha varchar,
    operacion integer DEFAULT NULL,
    status varchar DEFAULT NULL
)
RETURNS TABLE (
    registros integer,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*) AS registros, COALESCE(SUM(b.importe),0) AS importe
    FROM ta_16_contratos a
    JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
    WHERE a.ctrol_aseo = ctrol_a
      AND (operacion IS NULL OR b.ctrol_operacion = operacion)
      AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND fecha
      AND (status IS NULL OR b.status_vigencia = status);
END;
$$ LANGUAGE plpgsql;