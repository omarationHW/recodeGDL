-- Stored Procedure: con16_detade_01
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos por contrato, periodo y tipo de reporte.
-- Generado para formulario: Rep_PadronContratos
-- Fecha: 2025-08-27 15:10:45

CREATE OR REPLACE FUNCTION con16_detade_01(par_Control INTEGER, par_Rep TEXT, par_Fecha TEXT)
RETURNS TABLE (
    concepto TEXT,
    importe_adeudos NUMERIC,
    importe_recargos NUMERIC,
    importe_multa NUMERIC,
    importe_gastos NUMERIC
) AS $$
BEGIN
    -- Ejemplo: Lógica simplificada, debe ajustarse a la lógica real de negocio
    RETURN QUERY
    SELECT 
        'Adeudo' AS concepto,
        SUM(CASE WHEN p.ctrol_operacion = 6 THEN p.importe ELSE 0 END) AS importe_adeudos,
        SUM(CASE WHEN p.ctrol_operacion = 7 THEN p.importe ELSE 0 END) AS importe_recargos,
        SUM(CASE WHEN p.ctrol_operacion = 8 THEN p.importe ELSE 0 END) AS importe_multa,
        SUM(CASE WHEN p.ctrol_operacion = 9 THEN p.importe ELSE 0 END) AS importe_gastos
    FROM ta_16_pagos p
    WHERE p.control_contrato = par_Control
      AND to_char(p.aso_mes_pago, 'YYYY-MM') <= par_Fecha
      AND (par_Rep = 'V' AND p.status_vigencia = 'V' OR par_Rep = 'A')
    GROUP BY p.control_contrato;
END;
$$ LANGUAGE plpgsql;