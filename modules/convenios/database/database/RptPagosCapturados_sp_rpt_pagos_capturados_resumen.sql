-- Stored Procedure: sp_rpt_pagos_capturados_resumen
-- Tipo: Report
-- Descripción: Obtiene resumen de pagos capturados agrupados por manzana y lote.
-- Generado para formulario: RptPagosCapturados
-- Fecha: 2025-08-27 15:43:01

CREATE OR REPLACE FUNCTION sp_rpt_pagos_capturados_resumen(p_subtipo integer)
RETURNS TABLE (
    manzana varchar(15),
    lote integer,
    total_pagos numeric(18,2),
    total_recargos numeric(18,2),
    cantidad_pagos integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.manzana,
        a.lote,
        SUM(c.importe_pago) AS total_pagos,
        SUM(c.importe_recargo) AS total_recargos,
        COUNT(*) AS cantidad_pagos
    FROM ta_17_con_reg_pred a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_predio = b.id_conv_diver
    JOIN ta_17_conv_pagos c ON b.id_conv_resto = c.id_conv_resto
    WHERE a.tipo = 14 AND a.subtipo = p_subtipo
    GROUP BY a.manzana, a.lote
    ORDER BY a.manzana, a.lote;
END;
$$ LANGUAGE plpgsql;