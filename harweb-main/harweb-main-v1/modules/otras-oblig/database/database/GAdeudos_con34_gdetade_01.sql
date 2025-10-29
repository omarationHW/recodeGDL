-- Stored Procedure: con34_gdetade_01
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos concentrado para un contrato.
-- Generado para formulario: GAdeudos
-- Fecha: 2025-08-27 23:20:17

CREATE OR REPLACE FUNCTION con34_gdetade_01(par_tab TEXT, par_Control INTEGER, par_Rep TEXT, par_Fecha TEXT)
RETURNS TABLE (
    concepto TEXT,
    importe_adeudos NUMERIC,
    importe_recargos NUMERIC,
    importe_multa NUMERIC,
    importe_gastos NUMERIC,
    importe_actualizacion NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, importe_adeudos, importe_recargos, importe_multa, importe_gastos, importe_actualizacion
    FROM t34_adeudos_concentrado
    WHERE cve_tab = par_tab AND id_34_datos = par_Control AND rep_tipo = par_Rep AND periodo = par_Fecha;
END;
$$ LANGUAGE plpgsql;