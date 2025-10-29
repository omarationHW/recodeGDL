-- Stored Procedure: sp_gadeudos_detalle
-- Tipo: Report
-- Descripción: Devuelve el detalle de adeudos para un control, periodo y tipo de reporte
-- Generado para formulario: GAdeudos
-- Fecha: 2025-08-28 12:49:54

CREATE OR REPLACE FUNCTION sp_gadeudos_detalle(par_tab TEXT, par_control TEXT, par_rep TEXT, par_fecha TEXT)
RETURNS TABLE(
    concepto TEXT,
    importe_adeudos NUMERIC,
    importe_recargos NUMERIC,
    importe_multas NUMERIC,
    importe_actualizacion NUMERIC,
    importe_gastos NUMERIC
) AS $$
DECLARE
    v_id_datos INTEGER;
    v_ano INTEGER;
    v_mes INTEGER;
BEGIN
    SELECT id_34_datos INTO v_id_datos FROM t34_datos WHERE cve_tab = par_tab AND control = par_control LIMIT 1;
    IF v_id_datos IS NULL THEN
        RETURN;
    END IF;
    v_ano := split_part(par_fecha, '-', 1)::INTEGER;
    v_mes := split_part(par_fecha, '-', 2)::INTEGER;
    RETURN QUERY
    SELECT c.concepto, c.importe_adeudos, c.importe_recargos, c.importe_multa, c.importe_actualizacion, c.importe_gastos
    FROM t34_conceptos c
    WHERE c.id_datos = v_id_datos
      AND (c.anio < v_ano OR (c.anio = v_ano AND c.mes <= v_mes))
    ORDER BY c.anio, c.mes;
END;
$$ LANGUAGE plpgsql;