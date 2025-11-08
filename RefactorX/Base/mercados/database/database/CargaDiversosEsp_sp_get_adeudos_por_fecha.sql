-- Stored Procedure: sp_get_adeudos_por_fecha
-- Tipo: CRUD
-- Descripción: Obtiene los adeudos pendientes para una fecha de pago específica, excluyendo los ya pagados.
-- Generado para formulario: CargaDiversosEsp
-- Fecha: 2025-08-26 19:48:04

CREATE OR REPLACE FUNCTION sp_get_adeudos_por_fecha(p_fecha_pago DATE)
RETURNS TABLE (
    cta_aplicacion INTEGER,
    fecing DATE,
    recing SMALLINT,
    cajing VARCHAR(2),
    opcaja INTEGER,
    colonia SMALLINT,
    letras VARCHAR(3),
    tipo_rbo VARCHAR(2),
    mes_desde SMALLINT,
    axo_desde SMALLINT,
    pagado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.cta_aplicacion, a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.letras, a.tipo_rbo, b.mes_desde, b.axo_desde, SUM(b.importe_cta) AS pagado
    FROM ta_12_ingreso a
    JOIN ta_12_importes b ON a.fecing = b.fecing AND a.recing = b.recing AND a.cajing = b.cajing AND a.opcaja = b.opcaja
    WHERE a.fecing = p_fecha_pago
      AND a.tipo_rbo = '12'
      AND (b.cta_aplicacion = 44514 OR b.cta_aplicacion = 44515)
      AND NOT EXISTS (
        SELECT 1 FROM ta_11_pagos_local pl
        WHERE pl.fecha_pago = a.fecing
          AND pl.oficina_pago = a.recing
          AND pl.caja_pago = a.cajing
          AND pl.operacion_pago = a.opcaja
      )
    GROUP BY b.cta_aplicacion, a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.letras, a.tipo_rbo, b.mes_desde, b.axo_desde
    ORDER BY a.fecing, a.recing, a.cajing, a.opcaja, a.colonia, a.tipo_rbo, b.mes_desde, b.axo_desde;
END;
$$ LANGUAGE plpgsql;