-- Stored Procedure: sp_procesos_dashboard
-- Tipo: Report
-- Descripción: Devuelve el resumen principal de contratos y pagos para el dashboard de procesos (simula AfterScroll).
-- Generado para formulario: uDM_Procesos
-- Fecha: 2025-08-27 15:45:14

CREATE OR REPLACE FUNCTION sp_procesos_dashboard(
    ctrol_a integer,
    fecha1 varchar,
    fecha2 varchar
)
RETURNS TABLE (
    contratos_total integer,
    contratos_vigentes integer,
    contratos_cancelados integer,
    pagos jsonb
) AS $$
DECLARE
    pagos_arr jsonb := '[]'::jsonb;
    op integer;
    op_nombre text;
    regs integer;
    imp numeric;
    v integer;
    c integer;
    p integer;
    s integer;
    opers integer[] := ARRAY[6,7,8];
    opers_nombres text[] := ARRAY['CN','EXE','CON'];
    i integer;
BEGIN
    -- Contratos
    SELECT COUNT(*) INTO contratos_total FROM ta_16_contratos WHERE ctrol_aseo = ctrol_a;
    SELECT COUNT(*) INTO contratos_vigentes FROM ta_16_contratos WHERE ctrol_aseo = ctrol_a AND status_vigencia = 'V';
    SELECT COUNT(*) INTO contratos_cancelados FROM ta_16_contratos WHERE ctrol_aseo = ctrol_a AND status_vigencia = 'C';
    -- Pagos por operación y status
    FOR i IN 1..array_length(opers,1) LOOP
        op := opers[i];
        op_nombre := opers_nombres[i];
        -- Total
        SELECT COUNT(*), COALESCE(SUM(b.importe),0) INTO regs, imp
        FROM ta_16_contratos a
        JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND fecha1;
        -- Por status
        SELECT COUNT(*) INTO v FROM ta_16_contratos a JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND fecha1 AND b.status_vigencia = 'V';
        SELECT COUNT(*) INTO c FROM ta_16_contratos a JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND fecha1 AND b.status_vigencia = 'C';
        SELECT COUNT(*) INTO p FROM ta_16_contratos a JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND fecha1 AND b.status_vigencia = 'P';
        SELECT COUNT(*) INTO s FROM ta_16_contratos a JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
        WHERE a.ctrol_aseo = ctrol_a AND b.ctrol_operacion = op AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND fecha1 AND b.status_vigencia = 'S';
        pagos_arr := pagos_arr || jsonb_build_object(
            'operacion', op,
            'operacion_nombre', op_nombre,
            'registros', regs,
            'importe', imp,
            'vigente', v,
            'cancelado', c,
            'pendiente', p,
            'suspendido', s
        );
    END LOOP;
    RETURN QUERY SELECT contratos_total, contratos_vigentes, contratos_cancelados, pagos_arr;
END;
$$ LANGUAGE plpgsql;