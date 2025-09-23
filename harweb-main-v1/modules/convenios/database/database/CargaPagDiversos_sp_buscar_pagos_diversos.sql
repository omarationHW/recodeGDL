-- Stored Procedure: sp_buscar_pagos_diversos
-- Tipo: Report
-- Descripción: Devuelve los pagos diversos pendientes de cargar a convenios, filtrados por fecha y recaudadora.
-- Generado para formulario: CargaPagDiversos
-- Fecha: 2025-08-27 14:03:24

-- PostgreSQL stored procedure for searching pending diverse payments
CREATE OR REPLACE FUNCTION sp_buscar_pagos_diversos(
    p_fecha_desde DATE,
    p_fecha_hasta DATE,
    p_recaudadora INTEGER
)
RETURNS TABLE(
    fecing DATE,
    recing INTEGER,
    cajing VARCHAR(10),
    opcaja INTEGER,
    colonia INTEGER,
    obra INTEGER,
    numero INTEGER,
    tipo_rbo VARCHAR(10),
    mes_desde INTEGER,
    axo_desde INTEGER,
    pagado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.obra, a.numero, a.tipo_rbo,
           b.mes_desde, b.axo_desde, SUM(b.importe_cta) AS pagado
    FROM cg_12_ingreso a
    JOIN cg_12_importes b ON a.fecing = b.fecing AND a.recing = b.recing AND a.cajing = b.cajing AND a.opcaja = b.opcaja
    WHERE a.fecing BETWEEN p_fecha_desde AND p_fecha_hasta
      AND a.recing = p_recaudadora
      AND b.cta_aplicacion IN (541000000,542000000,543000000,925400010,925400020,925400030)
      AND NOT EXISTS (
        SELECT 1 FROM ta_17_pagos tp
        WHERE tp.fecha_pago = a.fecing AND tp.oficina_pago = a.recing AND tp.caja_pago = a.cajing AND tp.operacion_pago = a.opcaja
      )
    GROUP BY a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.obra, a.numero, a.tipo_rbo, b.mes_desde, b.axo_desde
    ORDER BY a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.obra, a.numero, a.tipo_rbo, b.mes_desde, b.axo_desde;
END;
$$ LANGUAGE plpgsql;