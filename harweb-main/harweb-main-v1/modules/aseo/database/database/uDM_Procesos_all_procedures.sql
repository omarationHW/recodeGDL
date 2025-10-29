-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: uDM_Procesos
-- Generado: 2025-08-27 15:45:14
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_tipo_aseo
-- Tipo: Catalog
-- Descripción: Obtiene los tipos de aseo. Si tipo=0, trae todos excepto los de Ctrol_Aseo=0; si no, filtra por Ctrol_Aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipo_aseo(tipo integer)
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar,
    descripcion varchar,
    cta_aplicacion integer
) AS $$
BEGIN
    IF tipo = 0 THEN
        RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo WHERE ctrol_aseo <> 0;
    ELSE
        RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo WHERE ctrol_aseo = tipo;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_dia_limite
-- Tipo: Catalog
-- Descripción: Obtiene el día límite para un mes dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dia_limite(mes integer)
RETURNS TABLE (
    mes integer,
    dia integer
) AS $$
BEGIN
    RETURN QUERY SELECT mes, dia FROM ta_16_dia_limite WHERE mes = $1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_get_contratos_count
-- Tipo: Report
-- Descripción: Cuenta contratos por ctrol_aseo y status_vigencia (si se provee).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_contratos_count(ctrol integer, status varchar DEFAULT NULL)
RETURNS TABLE (
    registros integer
) AS $$
BEGIN
    IF status IS NULL THEN
        RETURN QUERY SELECT COUNT(*) FROM ta_16_contratos WHERE ctrol_aseo = ctrol;
    ELSE
        RETURN QUERY SELECT COUNT(*) FROM ta_16_contratos WHERE ctrol_aseo = ctrol AND status_vigencia = status;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_get_pagos_summary
-- Tipo: Report
-- Descripción: Resumen de pagos: cuenta y suma importe por ctrol_aseo, fecha, operación y status_vigencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagos_summary(
    ctrol_a integer,
    fecha varchar,
    operacion integer DEFAULT NULL,
    status varchar DEFAULT NULL
)
RETURNS TABLE (
    registros integer,
    importe numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT COUNT(*) AS registros, COALESCE(SUM(b.importe),0) AS importe
    FROM ta_16_contratos a
    JOIN ta_16_pagos b ON b.control_contrato = a.control_contrato
    WHERE a.ctrol_aseo = ctrol_a
      AND (operacion IS NULL OR b.ctrol_operacion = operacion)
      AND b.aso_mes_pago BETWEEN a.aso_mes_oblig AND fecha
      AND (status IS NULL OR b.status_vigencia = status);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_procesos_dashboard
-- Tipo: Report
-- Descripción: Devuelve el resumen principal de contratos y pagos para el dashboard de procesos (simula AfterScroll).
-- --------------------------------------------

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

-- ============================================

