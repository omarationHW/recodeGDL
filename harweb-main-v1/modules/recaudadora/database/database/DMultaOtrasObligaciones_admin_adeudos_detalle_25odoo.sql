-- Stored Procedure: admin_adeudos_detalle_25odoo
-- Tipo: CRUD
-- Descripción: Obtiene detalle de adeudos para Otras Obligaciones
-- Generado para formulario: DMultaOtrasObligaciones
-- Fecha: 2025-08-27 00:31:21

CREATE OR REPLACE FUNCTION admin_adeudos_detalle_25odoo(par_tabla TEXT, par_control TEXT, pref TEXT)
RETURNS TABLE (
    rubro INTEGER,
    concepto INTEGER,
    cuenta_aplicacion INTEGER,
    referencia TEXT,
    descripcion TEXT,
    monto NUMERIC,
    acumulado NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.rubro,
        d.concepto,
        d.cuenta_aplicacion,
        d.referencia,
        d.descripcion,
        d.monto,
        d.acumulado
    FROM t34_detalle d
    WHERE d.tabla = par_tabla AND d.control = par_control;
END;
$$ LANGUAGE plpgsql;