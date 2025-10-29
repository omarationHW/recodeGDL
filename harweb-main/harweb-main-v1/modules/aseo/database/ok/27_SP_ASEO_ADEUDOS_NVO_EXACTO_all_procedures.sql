-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: Adeudos_Nvo (EXACTO del archivo original)
-- Archivo: 27_SP_ASEO_ADEUDOS_NVO_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: con16_detade_01
-- Tipo: Report
-- Descripción: Obtiene el estado de cuenta concentrado de un contrato (adeudos, recargos, multas, gastos, actualización) para un periodo y vigencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION con16_detade_01(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    concepto varchar,
    importe_adeudos numeric,
    importe_recargos numeric,
    importe_multa numeric,
    importe_gastos numeric,
    importe_act numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'Adeudos' as concepto,
        SUM(CASE WHEN ctrol_operacion = 6 THEN importe ELSE 0 END) as importe_adeudos,
        SUM(CASE WHEN ctrol_operacion = 9 THEN importe ELSE 0 END) as importe_recargos,
        SUM(CASE WHEN ctrol_operacion = 8 THEN importe ELSE 0 END) as importe_multa,
        SUM(CASE WHEN ctrol_operacion = 7 THEN importe ELSE 0 END) as importe_gastos,
        SUM(CASE WHEN ctrol_operacion = 10 THEN importe ELSE 0 END) as importe_act
    FROM public.ta_16_pagos
    WHERE control_contrato = par_Control
      AND status_vigencia = par_Rep
      AND to_char(aso_mes_pago, 'YYYY-MM') <= par_Fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: con16_detade_02
-- Tipo: Report
-- Descripción: Obtiene el estado de cuenta detallado de un contrato (por concepto, cantidad, adeudos+multas, recargos+gastos, actualización) para un periodo y vigencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION con16_detade_02(par_Control integer, par_Rep varchar, par_Fecha varchar)
RETURNS TABLE(
    concepto varchar,
    cant_recolec integer,
    importe_adeudos_multa numeric,
    importe_recargos_gastos numeric,
    importe_act numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.descripcion as concepto,
        p.exedencias as cant_recolec,
        SUM(CASE WHEN p.ctrol_operacion IN (6,8) THEN p.importe ELSE 0 END) as importe_adeudos_multa,
        SUM(CASE WHEN p.ctrol_operacion IN (7,9) THEN p.importe ELSE 0 END) as importe_recargos_gastos,
        SUM(CASE WHEN p.ctrol_operacion = 10 THEN p.importe ELSE 0 END) as importe_act
    FROM public.ta_16_pagos p
    JOIN public.ta_16_operacion o ON o.ctrol_operacion = p.ctrol_operacion
    WHERE p.control_contrato = par_Control
      AND p.status_vigencia = par_Rep
      AND to_char(p.aso_mes_pago, 'YYYY-MM') <= par_Fecha
    GROUP BY o.descripcion, p.exedencias;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp16_adeudos_f02
-- Tipo: Report
-- Descripción: Obtiene el estado de cuenta F02 (por periodo, concepto, cantidades, adeudos, recargos, multas, gastos, actualización) para un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_adeudos_f02(p_tipo varchar, p_numero integer, p_rep varchar, pref varchar)
RETURNS TABLE(
    periodo varchar,
    concepto varchar,
    cant_recolec integer,
    importe_adeudos numeric,
    importe_recargos numeric,
    importe_multa numeric,
    importe_gastos numeric,
    actualizacion numeric
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        to_char(p.aso_mes_pago, 'YYYY-MM') as periodo,
        o.descripcion as concepto,
        p.exedencias as cant_recolec,
        SUM(CASE WHEN p.ctrol_operacion = 6 THEN p.importe ELSE 0 END) as importe_adeudos,
        SUM(CASE WHEN p.ctrol_operacion = 9 THEN p.importe ELSE 0 END) as importe_recargos,
        SUM(CASE WHEN p.ctrol_operacion = 8 THEN p.importe ELSE 0 END) as importe_multa,
        SUM(CASE WHEN p.ctrol_operacion = 7 THEN p.importe ELSE 0 END) as importe_gastos,
        SUM(CASE WHEN p.ctrol_operacion = 10 THEN p.importe ELSE 0 END) as actualizacion
    FROM public.ta_16_pagos p
    JOIN public.ta_16_operacion o ON o.ctrol_operacion = p.ctrol_operacion
    WHERE p.control_contrato = p_numero
      AND p.status_vigencia = p_rep
      AND to_char(p.aso_mes_pago, 'YYYY-MM') <= pref
    GROUP BY periodo, o.descripcion, p.exedencias
    ORDER BY periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================