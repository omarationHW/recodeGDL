-- Stored Procedure: con34_gdetade_01
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos de una concesión específica.
-- Generado para formulario: GRep_Padron
-- Fecha: 2025-08-28 13:21:45

CREATE OR REPLACE FUNCTION con34_gdetade_01(par_tab integer, par_control integer, par_rep text, par_fecha text)
RETURNS TABLE(
    concepto text,
    importe_adeudos numeric,
    importe_recargos numeric,
    importe_multa numeric,
    importe_gastos numeric,
    importe_actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT concepto, importe_adeudos, importe_recargos, importe_multa, importe_gastos, importe_actualizacion
    FROM t34_adeudos_detalle
    WHERE cve_tab = par_tab
      AND id_34_datos = par_control
      AND rep_tipo = par_rep
      AND periodo = par_fecha;
END;
$$ LANGUAGE plpgsql;