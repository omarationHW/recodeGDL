-- Stored Procedure: rpt_adeudos_conv_diversos_detalle
-- Tipo: Report
-- Descripción: Detalle de pagos y parcialidades de un convenio diverso.
-- Generado para formulario: RptAdeudosConvDiversos
-- Fecha: 2025-08-27 15:23:56

CREATE OR REPLACE FUNCTION rpt_adeudos_conv_diversos_detalle(
    p_id_conv_diver integer
) RETURNS TABLE(
    id_conv_resto integer,
    fecha_pago date,
    importe_pago numeric,
    importe_recargo numeric,
    pago_parcial integer,
    total_parciales integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cp.id_conv_resto,
        cp.fecha_pago,
        cp.importe_pago,
        cp.importe_recargo,
        cp.pago_parcial,
        cp.total_parciales
    FROM ta_17_conv_pagos cp
    JOIN ta_17_conv_d_resto cr ON cp.id_conv_resto = cr.id_conv_resto
    WHERE cr.id_conv_diver = p_id_conv_diver
    ORDER BY cp.fecha_pago;
END;
$$ LANGUAGE plpgsql;