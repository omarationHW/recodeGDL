-- Stored Procedure: rpt_adeudos_conv_diversos_resumen
-- Tipo: Report
-- Descripción: Resumen de adeudos de convenios diversos agrupado por zona y estado.
-- Generado para formulario: RptAdeudosConvDiversos
-- Fecha: 2025-08-27 15:23:56

CREATE OR REPLACE FUNCTION rpt_adeudos_conv_diversos_resumen(
    p_tipo integer,
    p_subtipo integer,
    p_letras varchar,
    p_estado varchar,
    p_fecha date
) RETURNS TABLE(
    zona varchar,
    total_convenios integer,
    total_costo numeric,
    total_pagos numeric,
    total_saldo numeric,
    total_recargos numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CASE a.letras_exp
            WHEN 'ZC1' THEN 'Zona Centro'
            WHEN 'ZO2' THEN 'Zona Olímpica'
            WHEN 'ZO3' THEN 'Zona Oblatos'
            WHEN 'ZM4' THEN 'Zona Minerva'
            WHEN 'ZC5' THEN 'Zona Cruz del Sur'
            ELSE a.letras_exp
        END AS zona,
        COUNT(DISTINCT a.id_conv_diver) AS total_convenios,
        SUM(b.cantidad_total) AS total_costo,
        SUM(COALESCE(c.pagos,0)) AS total_pagos,
        SUM(b.cantidad_total - COALESCE(c.pagos,0)) AS total_saldo,
        SUM(COALESCE(c.recargos,0)) AS total_recargos
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    LEFT JOIN (
        SELECT id_conv_resto, SUM(importe_pago) AS pagos, SUM(importe_recargo) AS recargos
        FROM ta_17_conv_pagos
        WHERE fecha_pago <= p_fecha
        GROUP BY id_conv_resto
    ) c ON b.id_conv_resto = c.id_conv_resto
    WHERE a.tipo = p_tipo
      AND a.subtipo = p_subtipo
      AND a.letras_exp = p_letras
      AND b.vigencia = p_estado
    GROUP BY zona;
END;
$$ LANGUAGE plpgsql;