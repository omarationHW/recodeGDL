-- Stored Procedure: sp_get_ingreso_captura
-- Tipo: Report
-- Descripción: Obtiene el resumen de pagos capturados por fecha de pago, caja y operación para un mercado y oficina específicos.
-- Generado para formulario: IngresoCaptura
-- Fecha: 2025-08-27 00:05:16

-- PostgreSQL stored procedure for IngresoCaptura
CREATE OR REPLACE FUNCTION sp_get_ingreso_captura(
    p_num_mercado integer,
    p_fecha_pago date,
    p_oficina_pago integer,
    p_caja_pago varchar,
    p_operacion_pago integer
)
RETURNS TABLE (
    fecha_pago date,
    caja_pago varchar,
    operacion_pago integer,
    pagos integer,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.fecha_pago,
        b.caja_pago,
        b.operacion_pago,
        COUNT(*) AS pagos,
        SUM(b.importe_pago) AS importe
    FROM ta_11_locales a
    JOIN ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_num_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = EXTRACT(MONTH FROM p_fecha_pago)
      AND b.oficina_pago = p_oficina_pago
      AND b.caja_pago = p_caja_pago
      AND b.operacion_pago = p_operacion_pago
    GROUP BY b.fecha_pago, b.caja_pago, b.operacion_pago
    ORDER BY b.fecha_pago, b.caja_pago;
END;
$$ LANGUAGE plpgsql;
