-- Stored Procedure: sp_get_admin_adeudos_detalle_tot
-- Tipo: Report
-- Descripción: Obtiene los totales de adeudos administrativos para un contrato/concesión y periodo.
-- Generado para formulario: GConsulta
-- Fecha: 2025-08-27 16:02:36

CREATE OR REPLACE FUNCTION sp_get_admin_adeudos_detalle_tot(par_Tabla integer, par_Control varchar, pref varchar)
RETURNS TABLE (
    cuenta_aplicacion integer,
    referencia varchar,
    monto numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT cuenta_aplicacion, referencia, monto
    FROM admin_adeudos_detalle_tot
    WHERE cve_tab = par_Tabla AND control = par_Control AND referencia = pref;
END;
$$ LANGUAGE plpgsql;