-- Stored Procedure: con16_detade_01
-- Tipo: Report
-- Descripción: Obtiene el estado de cuenta concentrado de un contrato (adeudos, recargos, multas, gastos, actualización) para un periodo y vigencia.
-- Generado para formulario: Adeudos_Nvo
-- Fecha: 2025-08-27 13:45:57

CREATE OR REPLACE FUNCTION con16_detade_01(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    concepto varchar,
    importe_adeudos numeric,
    importe_recargos numeric,
    importe_multa numeric,
    importe_gastos numeric,
    importe_act numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'Adeudos' as concepto,
        SUM(CASE WHEN ctrol_operacion = 6 THEN importe ELSE 0 END) as importe_adeudos,
        SUM(CASE WHEN ctrol_operacion = 9 THEN importe ELSE 0 END) as importe_recargos,
        SUM(CASE WHEN ctrol_operacion = 8 THEN importe ELSE 0 END) as importe_multa,
        SUM(CASE WHEN ctrol_operacion = 7 THEN importe ELSE 0 END) as importe_gastos,
        SUM(CASE WHEN ctrol_operacion = 10 THEN importe ELSE 0 END) as importe_act
    FROM ta_16_pagos
    WHERE control_contrato = par_Control
      AND status_vigencia = par_Rep
      AND to_char(aso_mes_pago, 'YYYY-MM') <= par_Fecha;
END;
$$ LANGUAGE plpgsql;