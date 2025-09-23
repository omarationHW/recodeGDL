-- Stored Procedure: sp_rpt_adeudos_conv_diversos_saldo_ant_saldo_anterior
-- Tipo: Report
-- Descripción: Obtiene el saldo anterior de un convenio diverso antes de una fecha dada.
-- Generado para formulario: RptAdeudosConvDiversosSaldoAnt
-- Fecha: 2025-08-27 15:25:27

CREATE OR REPLACE FUNCTION sp_rpt_adeudos_conv_diversos_saldo_ant_saldo_anterior(
    p_tipo integer,
    p_subtipo integer,
    p_id_conv_diver integer,
    p_fechadsd date
)
RETURNS TABLE (
    id_conv_diver integer,
    tipo integer,
    cantidad_total numeric,
    pagos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_conv_diver,
        a.tipo,
        b.cantidad_total,
        COALESCE(SUM(c.importe_pago),0) AS pagos
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    LEFT JOIN ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND c.fecha_pago < p_fechadsd
    WHERE a.tipo = p_tipo
      AND a.subtipo = p_subtipo
      AND a.id_conv_diver = p_id_conv_diver
    GROUP BY a.id_conv_diver, a.tipo, b.cantidad_total;
END;
$$ LANGUAGE plpgsql;