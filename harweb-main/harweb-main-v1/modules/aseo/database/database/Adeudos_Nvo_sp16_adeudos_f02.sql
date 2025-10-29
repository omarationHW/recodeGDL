-- Stored Procedure: sp16_adeudos_f02
-- Tipo: Report
-- Descripción: Obtiene el estado de cuenta F02 (por periodo, concepto, cantidades, adeudos, recargos, multas, gastos, actualización) para un contrato.
-- Generado para formulario: Adeudos_Nvo
-- Fecha: 2025-08-27 13:45:57

CREATE OR REPLACE FUNCTION sp16_adeudos_f02(p_tipo varchar, p_numero integer, p_rep varchar, pref varchar)
RETURNS TABLE(
    periodo varchar,
    concepto varchar,
    cant_recolec integer,
    importe_adeudos numeric,
    importe_recargos numeric,
    importe_multa numeric,
    importe_gastos numeric,
    actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        to_char(p.aso_mes_pago, 'YYYY-MM') as periodo,
        o.descripcion as concepto,
        p.exedencias as cant_recolec,
        SUM(CASE WHEN p.ctrol_operacion = 6 THEN p.importe ELSE 0 END) as importe_adeudos,
        SUM(CASE WHEN p.ctrol_operacion = 9 THEN p.importe ELSE 0 END) as importe_recargos,
        SUM(CASE WHEN p.ctrol_operacion = 8 THEN p.importe ELSE 0 END) as importe_multa,
        SUM(CASE WHEN p.ctrol_operacion = 7 THEN p.importe ELSE 0 END) as importe_gastos,
        SUM(CASE WHEN p.ctrol_operacion = 10 THEN p.importe ELSE 0 END) as actualizacion
    FROM ta_16_pagos p
    JOIN ta_16_operacion o ON o.ctrol_operacion = p.ctrol_operacion
    WHERE p.control_contrato = p_numero
      AND p.status_vigencia = p_rep
      AND to_char(p.aso_mes_pago, 'YYYY-MM') <= pref
    GROUP BY periodo, o.descripcion, p.exedencias
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;