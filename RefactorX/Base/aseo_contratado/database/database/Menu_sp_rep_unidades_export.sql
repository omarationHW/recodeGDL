-- Stored Procedure: sp_rep_unidades_export
-- Tipo: Report
-- Descripción: Reporte/exportación de unidades de recolección por ejercicio y orden.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_rep_unidades_export(p_ejercicio INTEGER, p_order_by VARCHAR)
RETURNS TABLE(id SERIAL, ejercicio INTEGER, clave VARCHAR, descripcion VARCHAR, costo_unidad NUMERIC, costo_exed NUMERIC) AS $$
BEGIN
    RETURN QUERY EXECUTE format('SELECT id, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed FROM ta_16_unidades WHERE ejercicio_recolec = %L ORDER BY %I', p_ejercicio, p_order_by);
END;
$$ LANGUAGE plpgsql;