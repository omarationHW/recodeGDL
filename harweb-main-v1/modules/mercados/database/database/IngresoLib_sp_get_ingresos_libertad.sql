-- Stored Procedure: sp_get_ingresos_libertad
-- Tipo: Report
-- Descripción: Obtiene los ingresos por fecha y caja para el Mercado Libertad en un mes/año.
-- Generado para formulario: IngresoLib
-- Fecha: 2025-08-27 00:06:35

CREATE OR REPLACE FUNCTION sp_get_ingresos_libertad(p_mes integer, p_anio integer, p_mercado integer)
RETURNS TABLE (
    fecha_pago date,
    caja_pago varchar,
    pagos integer,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.fecha_pago, b.caja_pago, COUNT(*) AS pagos, SUM(b.importe_pago) AS importe
    FROM ta_11_locales a
    JOIN ta_11_pagos_local b ON a.id_local = b.id_local
    WHERE a.num_mercado = p_mercado
      AND EXTRACT(MONTH FROM b.fecha_pago) = p_mes
      AND EXTRACT(YEAR FROM b.fecha_pago) = p_anio
    GROUP BY b.fecha_pago, b.caja_pago
    ORDER BY b.fecha_pago, b.caja_pago;
END;
$$ LANGUAGE plpgsql;