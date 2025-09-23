-- Stored Procedure: sp_saldo_anterior_predio
-- Tipo: Report
-- Descripción: Obtiene el saldo anterior de un predio regularizado antes de una fecha dada.
-- Generado para formulario: RptAdeudoCorteManzanaSaldoAnt
-- Fecha: 2025-08-27 15:20:14

-- PostgreSQL stored procedure for saldo anterior
CREATE OR REPLACE FUNCTION sp_saldo_anterior_predio(
    p_subtipo integer,
    p_id_conv_predio integer,
    p_fechadsd date
)
RETURNS TABLE (
    id_conv_predio integer,
    tipo smallint,
    cantidad_total numeric,
    pagos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id_conv_predio,
        a.tipo,
        b.cantidad_total,
        COALESCE(SUM(c.importe_pago),0) AS pagos
    FROM ta_17_con_reg_pred a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    LEFT JOIN ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto AND c.fecha_pago < p_fechadsd
    WHERE a.tipo = 14
      AND a.subtipo = p_subtipo
      AND a.id_conv_predio = p_id_conv_predio
    GROUP BY a.id_conv_predio, a.tipo, b.cantidad_total;
END;
$$ LANGUAGE plpgsql;