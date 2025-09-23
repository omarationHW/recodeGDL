-- Stored Procedure: spd_17_recaudacion
-- Tipo: Report
-- Descripción: Obtiene recaudación por rango de fechas y clasificación
-- Generado para formulario: EstadisticasContratos
-- Fecha: 2025-08-27 14:35:30

-- PostgreSQL version of spd_17_recaudacion
CREATE OR REPLACE FUNCTION spd_17_recaudacion(fecha_desde date, fecha_hasta date, clasificacion text)
RETURNS TABLE(
    fecha_pago date,
    oficina_pago integer,
    caja_pago varchar,
    importe numeric,
    clasificacion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.fecha_pago,
        p.oficina_pago,
        p.caja_pago,
        p.importe,
        clasificacion
    FROM ta_17_pagos p
    WHERE p.fecha_pago BETWEEN fecha_desde AND fecha_hasta;
END;
$$ LANGUAGE plpgsql;