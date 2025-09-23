-- Stored Procedure: rptreq_pba_aseo_get_report
-- Tipo: Report
-- Descripción: Obtiene el reporte de requerimiento de pago y embargo de aseo contratado, incluyendo cálculo de recargos y gastos.
-- Generado para formulario: RptReq_Pba_Aseo
-- Fecha: 2025-08-27 15:15:15

CREATE OR REPLACE FUNCTION rptreq_pba_aseo_get_report(
    p_id_rec INTEGER,
    p_tipo_aseo TEXT DEFAULT 'todos',
    p_fecha_corte DATE
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    tipo_aseo TEXT,
    descripcion_1 TEXT,
    domicilio TEXT,
    zona TEXT,
    aso_mes_pago DATE,
    importe NUMERIC,
    recargos NUMERIC,
    gastos NUMERIC,
    total NUMERIC
) AS $$
DECLARE
    vaxo INTEGER;
    vmes INTEGER;
    vdia INTEGER;
    vlimite RECORD;
    vxmes TEXT;
    vperiodo TEXT;
    vtotal NUMERIC;
    vtotal1 NUMERIC;
    vgastos NUMERIC;
    vporcentaje NUMERIC;
    vrecargos NUMERIC;
    v_gastos_row RECORD;
    v_gastos_min NUMERIC;
    v_gastos_max NUMERIC;
    v_gastos_calc NUMERIC;
    vtotal_final NUMERIC;
    r RECORD;
BEGIN
    -- Obtener año, mes, día de la fecha de corte
    vaxo := EXTRACT(YEAR FROM p_fecha_corte)::INTEGER;
    vmes := EXTRACT(MONTH FROM p_fecha_corte)::INTEGER;
    vdia := EXTRACT(DAY FROM p_fecha_corte)::INTEGER;

    -- Obtener límite de día para el mes
    SELECT * INTO vlimite FROM ta_16_dia_limite WHERE mes = vmes LIMIT 1;
    IF FOUND THEN
        IF vlimite.dia <= vdia THEN
            vxmes := LPAD((vmes-1)::TEXT, 2, '0');
        ELSE
            vxmes := LPAD(vmes::TEXT, 2, '0');
        END IF;
    ELSE
        vxmes := LPAD(vmes::TEXT, 2, '0');
    END IF;

    -- Cursor para recorrer los adeudos
    FOR r IN
        SELECT a.control_contrato, a.num_contrato, c.tipo_aseo, d.descripcion AS descripcion_1, a.domicilio, f.zona, b.aso_mes_pago, b.importe,
            a.ctrol_aseo, b.ctrol_operacion, b.status_vigencia, b.ctrol_operacion, b.exedencias, b.cantidad_recolec, b.cve_operacion
        FROM ta_16_contratos a
        JOIN ta_16_pagos b ON a.control_contrato = b.control_contrato
        JOIN ta_16_tipo_aseo c ON a.ctrol_aseo = c.ctrol_aseo
        JOIN ta_16_empresas d ON a.num_empresa = d.num_empresa
        JOIN ta_16_operacion e ON b.ctrol_operacion = e.ctrol_operacion
        JOIN ta_16_zonas f ON a.ctrol_zona = f.ctrol_zona
        WHERE b.status_vigencia = 'V'
          AND a.id_rec = p_id_rec
          AND b.aso_mes_pago <= (vaxo::TEXT || '-' || vxmes)
          AND (p_tipo_aseo = 'todos' OR c.tipo_aseo = p_tipo_aseo)
        ORDER BY a.control_contrato, b.aso_mes_pago
    LOOP
        -- Calcular recargos
        vporcentaje := 0;
        SELECT COALESCE(SUM(porcentaje_mes),0) INTO vporcentaje
        FROM ta_12_recargos
        WHERE (axo = EXTRACT(YEAR FROM r.aso_mes_pago)::INTEGER AND mes >= EXTRACT(MONTH FROM r.aso_mes_pago)::INTEGER)
           OR (axo = vaxo AND mes <= vmes)
           OR (axo > EXTRACT(YEAR FROM r.aso_mes_pago)::INTEGER AND axo < vaxo);
        IF vporcentaje > 250 THEN
            vporcentaje := 250;
        END IF;
        vrecargos := ROUND((r.importe * vporcentaje) / 100.0, 2);

        -- Calcular gastos
        SELECT * INTO v_gastos_row FROM ta_15_gastos WHERE fecha_axo = vaxo AND fecha_mes = vmes LIMIT 1;
        IF FOUND THEN
            v_gastos_min := v_gastos_row.gtos_requer;
            v_gastos_max := v_gastos_row.gtos_requer_anual;
        ELSE
            v_gastos_min := 0;
            v_gastos_max := 0;
        END IF;
        v_gastos_calc := r.importe * 0.03;
        IF v_gastos_calc > v_gastos_max THEN
            v_gastos_calc := v_gastos_max;
        ELSIF v_gastos_calc < v_gastos_min THEN
            v_gastos_calc := v_gastos_min;
        END IF;

        vtotal_final := r.importe + vrecargos + (r.importe * 0.5) + v_gastos_calc;

        RETURN NEXT (
            r.control_contrato,
            r.num_contrato,
            r.tipo_aseo,
            r.descripcion_1,
            r.domicilio,
            r.zona,
            r.aso_mes_pago,
            r.importe,
            vrecargos,
            v_gastos_calc,
            vtotal_final
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;