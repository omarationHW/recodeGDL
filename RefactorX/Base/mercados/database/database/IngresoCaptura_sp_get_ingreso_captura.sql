-- Stored Procedure: sp_get_ingreso_captura
-- Tipo: Report
-- Descripción: Obtiene el resumen de pagos capturados por fecha de pago, caja y operación para un mercado y oficina específicos.
-- Generado para formulario: IngresoCaptura
-- Fecha: 2025-08-27 00:05:16

DROP FUNCTION IF EXISTS sp_get_ingreso_captura(SMALLINT, DATE, SMALLINT, CHAR, INTEGER);

CREATE OR REPLACE FUNCTION sp_get_ingreso_captura(
    p_num_mercado SMALLINT,
    p_fecha_pago DATE,
    p_oficina_pago SMALLINT,
    p_caja_pago CHAR(2),
    p_operacion_pago INTEGER
)
RETURNS TABLE (
    fecha_pago DATE,
    caja_pago CHAR(2),
    operacion_pago INTEGER,
    pagos BIGINT,
    importe NUMERIC(16,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.fecha_pago,
        b.caja_pago,
        b.operacion_pago,
        COUNT(*)::BIGINT AS pagos,
        COALESCE(SUM(b.importe_pago), 0)::NUMERIC(16,2) AS importe
    FROM publico.ta_11_locales a
    JOIN publico.ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_num_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = EXTRACT(MONTH FROM p_fecha_pago)
      AND b.oficina_pago = p_oficina_pago
      AND b.caja_pago = p_caja_pago
      AND b.operacion_pago = p_operacion_pago
    GROUP BY b.fecha_pago, b.caja_pago, b.operacion_pago
    ORDER BY b.fecha_pago, b.caja_pago;
END;
$$ LANGUAGE plpgsql;
