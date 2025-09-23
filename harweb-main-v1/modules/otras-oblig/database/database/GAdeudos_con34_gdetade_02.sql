-- Stored Procedure: con34_gdetade_02
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos a nivel periodo para un contrato.
-- Generado para formulario: GAdeudos
-- Fecha: 2025-08-27 23:20:17

CREATE OR REPLACE FUNCTION con34_gdetade_02(par_tab TEXT, par_Control INTEGER, par_Rep TEXT, par_Fecha TEXT)
RETURNS TABLE (
    concepto TEXT,
    cant_recolec INTEGER,
    importe_adeudos NUMERIC,
    importe_recargos NUMERIC,
    importe_multas NUMERIC,
    importe_actualizacion NUMERIC,
    importe_gastos NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, cant_recolec, importe_adeudos, importe_recargos, importe_multas, importe_actualizacion, importe_gastos
    FROM t34_adeudos_detalle
    WHERE cve_tab = par_tab AND id_34_datos = par_Control AND rep_tipo = par_Rep AND periodo = par_Fecha;
END;
$$ LANGUAGE plpgsql;