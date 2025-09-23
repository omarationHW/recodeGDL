-- Stored Procedure: sp_get_admin_adeudos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de adeudos administrativos para un contrato/concesión y periodo.
-- Generado para formulario: GConsulta
-- Fecha: 2025-08-27 16:02:36

CREATE OR REPLACE FUNCTION sp_get_admin_adeudos_detalle(par_Tabla integer, par_Control varchar, pref varchar)
RETURNS TABLE (
    rubro integer,
    concepto integer,
    cuenta_aplicacion integer,
    referencia varchar,
    descripcion varchar,
    monto numeric,
    acumulado numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT rubro, concepto, cuenta_aplicacion, referencia, descripcion, monto, acumulado
    FROM admin_adeudos_detalle
    WHERE cve_tab = par_Tabla AND control = par_Control AND referencia = pref;
END;
$$ LANGUAGE plpgsql;