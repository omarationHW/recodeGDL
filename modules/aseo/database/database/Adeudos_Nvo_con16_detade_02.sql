-- Stored Procedure: con16_detade_02
-- Tipo: Report
-- Descripción: Obtiene el estado de cuenta detallado de un contrato (por concepto, cantidad, adeudos+multas, recargos+gastos, actualización) para un periodo y vigencia.
-- Generado para formulario: Adeudos_Nvo
-- Fecha: 2025-08-27 13:45:57

CREATE OR REPLACE FUNCTION con16_detade_02(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    concepto varchar,
    cant_recolec integer,
    importe_adeudos_multa numeric,
    importe_recargos_gastos numeric,
    importe_act numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.descripcion as concepto,
        p.exedencias as cant_recolec,
        SUM(CASE WHEN p.ctrol_operacion IN (6,8) THEN p.importe ELSE 0 END) as importe_adeudos_multa,
        SUM(CASE WHEN p.ctrol_operacion IN (7,9) THEN p.importe ELSE 0 END) as importe_recargos_gastos,
        SUM(CASE WHEN p.ctrol_operacion = 10 THEN p.importe ELSE 0 END) as importe_act
    FROM ta_16_pagos p
    JOIN ta_16_operacion o ON o.ctrol_operacion = p.ctrol_operacion
    WHERE p.control_contrato = par_Control
      AND p.status_vigencia = par_Rep
      AND to_char(p.aso_mes_pago, 'YYYY-MM') <= par_Fecha
    GROUP BY o.descripcion, p.exedencias;
END;
$$ LANGUAGE plpgsql;