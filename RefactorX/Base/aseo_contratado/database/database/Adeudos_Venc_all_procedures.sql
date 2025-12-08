-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Adeudos_Venc
-- Base de datos: aseo_contratado
-- Actualizado: 2025-12-07
-- Total SPs: 6
-- ============================================
-- Descripción: Consulta de adeudos vencidos de un contrato
-- Flujo Delphi Original:
--   1. Ingresar num_contrato y tipo_aseo
--   2. Obtener dia_limite del mes actual
--   3. Buscar contrato con BuscaCont (datos completos)
--   4. Buscar adeudos vencidos (cuota normal + exedencias)
--   5. Calcular recargos desde ta_16_recargos
--   6. Buscar apremios/requerimientos en ta_15_apremios
--   7. Imprimir reporte ppRepEdoCta
-- ============================================

-- SP 1/6: sp_aseo_get_dia_limite
-- Tipo: Catalog
-- Descripción: Obtiene el día límite del mes para determinar vencimientos
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_get_dia_limite(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_get_dia_limite(
    p_mes INTEGER
)
RETURNS TABLE (
    mes INTEGER,
    dia INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT dl.mes::INTEGER, dl.dia::INTEGER
    FROM ta_16_dia_limite dl
    WHERE dl.mes = p_mes;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_get_dia_limite(INTEGER) TO PUBLIC;

-- ============================================
-- SP 2/6: sp_aseo_buscar_contrato_completo
-- Tipo: CRUD
-- Descripción: Busca contrato con todos los datos relacionados
-- Equivalente a BuscaCont del Delphi
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_buscar_contrato_completo(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_buscar_contrato_completo(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER
)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    tipo_emp VARCHAR,
    nom_emp VARCHAR,
    representante VARCHAR,
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    desc_aseo VARCHAR,
    ctrol_recolec INTEGER,
    cve_recolec VARCHAR,
    desc_recolec VARCHAR,
    cantidad_recolec INTEGER,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    zona INTEGER,
    sub_zona INTEGER,
    nom_zona VARCHAR,
    id_rec INTEGER,
    recaudadora VARCHAR,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig DATE,
    cve VARCHAR,
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.num_empresa::INTEGER,
        a.ctrol_emp::INTEGER,
        b.tipo_empresa::VARCHAR,
        b.descripcion::VARCHAR as tipo_emp,
        a.descripcion::VARCHAR as nom_emp,
        a.representante::VARCHAR,
        c.control_contrato::INTEGER,
        c.num_contrato::INTEGER,
        c.ctrol_aseo::INTEGER,
        d.tipo_aseo::VARCHAR,
        d.descripcion::VARCHAR as desc_aseo,
        c.ctrol_recolec::INTEGER,
        e.cve_recolec::VARCHAR,
        e.descripcion::VARCHAR as desc_recolec,
        COALESCE(c.cantidad_recolec, 0)::INTEGER,
        c.domicilio::VARCHAR,
        c.sector::VARCHAR,
        c.ctrol_zona::INTEGER,
        f.zona::INTEGER,
        f.sub_zona::INTEGER,
        f.descripcion::VARCHAR as nom_zona,
        c.id_rec::INTEGER,
        g.recaudadora::VARCHAR,
        c.fecha_hora_alta::TIMESTAMP,
        c.status_vigencia::VARCHAR,
        c.aso_mes_oblig::DATE,
        c.cve::VARCHAR,
        c.usuario::INTEGER,
        c.fecha_hora_baja::TIMESTAMP
    FROM ta_16_empresas a
    INNER JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    INNER JOIN ta_16_contratos c ON c.num_empresa = a.num_empresa AND c.ctrol_emp = a.ctrol_emp
    INNER JOIN ta_16_tipo_aseo d ON d.ctrol_aseo = c.ctrol_aseo
    INNER JOIN ta_16_unidades e ON e.ctrol_recolec = c.ctrol_recolec
    INNER JOIN ta_16_zonas f ON f.ctrol_zona = c.ctrol_zona
    INNER JOIN ta_12_recaudadoras g ON g.id_rec = c.id_rec
    WHERE c.num_contrato = p_num_contrato
      AND c.ctrol_aseo = p_ctrol_aseo
    ORDER BY c.num_contrato;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_buscar_contrato_completo(INTEGER, INTEGER) TO PUBLIC;

-- ============================================
-- SP 3/6: sp_aseo_adeudos_vencidos_contrato
-- Tipo: Report
-- Descripción: Busca adeudos vencidos (cuota normal + exedencias)
-- Equivalente a QryBusqContAfterScroll del Delphi
-- CAM: A=Cuota Normal Vencida, B=Cuota Normal Posterior
--      C=Exedencia Vencida, D=Exedencia Posterior
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_adeudos_vencidos_contrato(INTEGER, INTEGER, VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_adeudos_vencidos_contrato(
    p_control_contrato INTEGER,
    p_dia_limite INTEGER,
    p_periodo_posterior VARCHAR DEFAULT NULL,  -- formato YYYY-MM si se quiere periodo posterior
    p_incluir_posteriores INTEGER DEFAULT 0
)
RETURNS TABLE (
    cam CHAR,
    control_contrato INTEGER,
    aso_mes_pago VARCHAR,
    ctrol_operacion INTEGER,
    descripcion VARCHAR,
    exedencias INTEGER,
    importe NUMERIC
) AS $$
DECLARE
    v_aso_hoy INTEGER;
    v_mes_hoy INTEGER;
    v_dia_hoy INTEGER;
    v_aso_pos INTEGER;
    v_mes_pos INTEGER;
BEGIN
    -- Obtener fecha actual
    v_aso_hoy := EXTRACT(YEAR FROM CURRENT_DATE);
    v_mes_hoy := EXTRACT(MONTH FROM CURRENT_DATE);
    v_dia_hoy := EXTRACT(DAY FROM CURRENT_DATE);

    -- Parsear periodo posterior si existe
    IF p_periodo_posterior IS NOT NULL THEN
        v_aso_pos := SPLIT_PART(p_periodo_posterior, '-', 1)::INTEGER;
        v_mes_pos := SPLIT_PART(p_periodo_posterior, '-', 2)::INTEGER;
    END IF;

    RETURN QUERY
    -- CUOTA NORMAL VENCIDA (ctrol_operacion = 6)
    SELECT 'A'::CHAR as cam,
           a.control_contrato::INTEGER,
           TO_CHAR(a.aso_mes_pago, 'YYYY-MM')::VARCHAR as aso_mes_pago,
           a.ctrol_operacion::INTEGER,
           b.descripcion::VARCHAR,
           COALESCE(a.exedencias, 0)::INTEGER,
           a.importe::NUMERIC
    FROM ta_16_pagos a
    INNER JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato
      AND a.ctrol_operacion = 6
      AND a.status_vigencia = 'V'
      AND (
          (v_dia_hoy > p_dia_limite AND a.aso_mes_pago <= make_date(v_aso_hoy, v_mes_hoy, 1))
          OR
          (v_dia_hoy <= p_dia_limite AND a.aso_mes_pago < make_date(v_aso_hoy, v_mes_hoy, 1))
      )

    UNION ALL

    -- CUOTA NORMAL POSTERIORES (si p_incluir_posteriores = 1)
    SELECT 'B'::CHAR as cam,
           a.control_contrato::INTEGER,
           TO_CHAR(a.aso_mes_pago, 'YYYY-MM')::VARCHAR as aso_mes_pago,
           a.ctrol_operacion::INTEGER,
           b.descripcion::VARCHAR,
           COALESCE(a.exedencias, 0)::INTEGER,
           a.importe::NUMERIC
    FROM ta_16_pagos a
    INNER JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato
      AND a.ctrol_operacion = 6
      AND a.status_vigencia = 'V'
      AND p_incluir_posteriores = 1
      AND p_periodo_posterior IS NOT NULL
      AND (
          (v_dia_hoy > p_dia_limite AND a.aso_mes_pago BETWEEN make_date(v_aso_hoy, v_mes_hoy + 1, 1) AND make_date(v_aso_pos, v_mes_pos, 1))
          OR
          (v_dia_hoy <= p_dia_limite AND a.aso_mes_pago BETWEEN make_date(v_aso_hoy, v_mes_hoy, 1) AND make_date(v_aso_pos, v_mes_pos, 1))
      )

    UNION ALL

    -- EXEDENCIAS VENCIDAS (ctrol_operacion <> 6)
    SELECT 'C'::CHAR as cam,
           a.control_contrato::INTEGER,
           TO_CHAR(a.aso_mes_pago, 'YYYY-MM')::VARCHAR as aso_mes_pago,
           a.ctrol_operacion::INTEGER,
           b.descripcion::VARCHAR,
           COALESCE(a.exedencias, 0)::INTEGER,
           a.importe::NUMERIC
    FROM ta_16_pagos a
    INNER JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato
      AND a.ctrol_operacion <> 6
      AND a.status_vigencia = 'V'
      AND (
          (v_dia_hoy > p_dia_limite AND a.aso_mes_pago <= (make_date(v_aso_hoy, v_mes_hoy, 1) - INTERVAL '2 months')::DATE)
          OR
          (v_dia_hoy <= p_dia_limite AND a.aso_mes_pago <= (make_date(v_aso_hoy, v_mes_hoy, 1) - INTERVAL '3 months')::DATE)
      )

    UNION ALL

    -- EXEDENCIAS POSTERIORES (si p_incluir_posteriores = 1)
    SELECT 'D'::CHAR as cam,
           a.control_contrato::INTEGER,
           TO_CHAR(a.aso_mes_pago, 'YYYY-MM')::VARCHAR as aso_mes_pago,
           a.ctrol_operacion::INTEGER,
           b.descripcion::VARCHAR,
           COALESCE(a.exedencias, 0)::INTEGER,
           a.importe::NUMERIC
    FROM ta_16_pagos a
    INNER JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato
      AND a.ctrol_operacion <> 6
      AND a.status_vigencia = 'V'
      AND p_incluir_posteriores = 1
      AND p_periodo_posterior IS NOT NULL
      AND (
          (v_dia_hoy > p_dia_limite AND a.aso_mes_pago BETWEEN (make_date(v_aso_hoy, v_mes_hoy, 1) - INTERVAL '1 month')::DATE AND make_date(v_aso_pos, v_mes_pos, 1))
          OR
          (v_dia_hoy <= p_dia_limite AND a.aso_mes_pago BETWEEN (make_date(v_aso_hoy, v_mes_hoy, 1) - INTERVAL '2 months')::DATE AND make_date(v_aso_pos, v_mes_pos, 1))
      )

    ORDER BY 3, 4;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_adeudos_vencidos_contrato(INTEGER, INTEGER, VARCHAR, INTEGER) TO PUBLIC;

-- ============================================
-- SP 4/6: sp_aseo_calcular_recargos
-- Tipo: Calc
-- Descripción: Calcula recargos para un adeudo basado en ta_16_recargos
-- Equivalente a QryAdeudosCalcFields del Delphi
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_calcular_recargos(VARCHAR, NUMERIC, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_calcular_recargos(
    p_aso_mes_pago VARCHAR,  -- formato YYYY-MM
    p_importe NUMERIC,
    p_ctrol_operacion INTEGER,
    p_dia_limite INTEGER
)
RETURNS NUMERIC AS $$
DECLARE
    v_aso_ade INTEGER;
    v_mes_ade INTEGER;
    v_aso_hoy INTEGER;
    v_mes_hoy INTEGER;
    v_dia_hoy INTEGER;
    v_sum_recargo NUMERIC;
    v_recargos NUMERIC;
BEGIN
    v_aso_hoy := EXTRACT(YEAR FROM CURRENT_DATE);
    v_mes_hoy := EXTRACT(MONTH FROM CURRENT_DATE);
    v_dia_hoy := EXTRACT(DAY FROM CURRENT_DATE);

    v_aso_ade := SPLIT_PART(p_aso_mes_pago, '-', 1)::INTEGER;
    v_mes_ade := SPLIT_PART(p_aso_mes_pago, '-', 2)::INTEGER;

    -- Si es exedencia (no cuota normal), ajustar periodo +2 meses
    IF p_ctrol_operacion <> 6 THEN
        IF v_mes_ade = 10 THEN
            v_mes_ade := 12;
        ELSIF v_mes_ade = 11 THEN
            v_aso_ade := v_aso_ade + 1;
            v_mes_ade := 1;
        ELSIF v_mes_ade = 12 THEN
            v_aso_ade := v_aso_ade + 1;
            v_mes_ade := 2;
        ELSE
            v_mes_ade := v_mes_ade + 2;
        END IF;
    END IF;

    -- Sumar porcentajes de recargo desde tabla ta_16_recargos
    IF v_dia_hoy > p_dia_limite THEN
        SELECT COALESCE(SUM(porc_recargo), 0) INTO v_sum_recargo
        FROM ta_16_recargos
        WHERE aso_mes_recargo BETWEEN make_date(v_aso_ade, v_mes_ade, 1)
                                  AND make_date(v_aso_hoy, v_mes_hoy, 1);
    ELSE
        IF v_mes_hoy > 1 THEN
            SELECT COALESCE(SUM(porc_recargo), 0) INTO v_sum_recargo
            FROM ta_16_recargos
            WHERE aso_mes_recargo BETWEEN make_date(v_aso_ade, v_mes_ade, 1)
                                      AND make_date(v_aso_hoy, v_mes_hoy - 1, 1);
        ELSE
            SELECT COALESCE(SUM(porc_recargo), 0) INTO v_sum_recargo
            FROM ta_16_recargos
            WHERE aso_mes_recargo BETWEEN make_date(v_aso_ade, v_mes_ade, 1)
                                      AND make_date(v_aso_hoy - 1, 12, 1);
        END IF;
    END IF;

    -- Calcular recargos: (importe * sum_recargo) / 100
    v_recargos := (p_importe * COALESCE(v_sum_recargo, 0)) / 100;

    RETURN ROUND(v_recargos, 2);
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_calcular_recargos(VARCHAR, NUMERIC, INTEGER, INTEGER) TO PUBLIC;

-- ============================================
-- SP 5/6: sp_aseo_buscar_apremios_contrato
-- Tipo: Report
-- Descripción: Busca apremios/requerimientos del contrato
-- Equivalente a QryBusqContCalcFields del Delphi
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_buscar_apremios_contrato(INTEGER);

CREATE OR REPLACE FUNCTION public.sp_aseo_buscar_apremios_contrato(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    id_control INTEGER,
    modulo INTEGER,
    control_otr INTEGER,
    folio INTEGER,
    importe_multa NUMERIC,
    importe_gastos NUMERIC,
    fecha_practicado DATE,
    clave_practicado VARCHAR,
    porcentaje_multa INTEGER,
    no_requerimientos INTEGER,
    folios_requerimientos VARCHAR,
    total_multas NUMERIC,
    total_gastos NUMERIC
) AS $$
DECLARE
    v_folios VARCHAR := '';
    v_count INTEGER := 0;
    v_tot_multa NUMERIC := 0;
    v_tot_gastos NUMERIC := 0;
    rec RECORD;
BEGIN
    -- Iterar sobre apremios para construir la lista de folios
    FOR rec IN
        SELECT a.id_control, a.modulo, a.control_otr, a.folio,
               a.importe_multa, a.importe_gastos,
               a.fecha_practicado, a.clave_practicado, a.porcentaje_multa
        FROM ta_15_apremios a
        WHERE a.modulo = 16
          AND a.control_otr = p_control_contrato
          AND a.vigencia = '1'
          AND a.clave_practicado = 'P'
        ORDER BY a.id_control
    LOOP
        v_count := v_count + 1;
        v_tot_multa := v_tot_multa + COALESCE(rec.importe_multa, 0);
        v_tot_gastos := v_tot_gastos + COALESCE(rec.importe_gastos, 0);

        IF v_folios = '' THEN
            v_folios := rec.folio::VARCHAR;
        ELSE
            v_folios := v_folios || ' - ' || rec.folio::VARCHAR;
        END IF;
    END LOOP;

    -- Retornar resultados
    RETURN QUERY
    SELECT a.id_control::INTEGER,
           a.modulo::INTEGER,
           a.control_otr::INTEGER,
           a.folio::INTEGER,
           a.importe_multa::NUMERIC,
           a.importe_gastos::NUMERIC,
           a.fecha_practicado::DATE,
           a.clave_practicado::VARCHAR,
           COALESCE(a.porcentaje_multa, 100)::INTEGER,
           v_count::INTEGER as no_requerimientos,
           v_folios::VARCHAR as folios_requerimientos,
           v_tot_multa::NUMERIC as total_multas,
           v_tot_gastos::NUMERIC as total_gastos
    FROM ta_15_apremios a
    WHERE a.modulo = 16
      AND a.control_otr = p_control_contrato
      AND a.vigencia = '1'
      AND a.clave_practicado = 'P'
    ORDER BY a.id_control
    LIMIT 1;

    -- Si no hay apremios, retornar registro vacío con totales
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT 0::INTEGER, 16::INTEGER, p_control_contrato::INTEGER, 0::INTEGER,
               0::NUMERIC, 0::NUMERIC, NULL::DATE, ''::VARCHAR, 100::INTEGER,
               0::INTEGER, ''::VARCHAR, 0::NUMERIC, 0::NUMERIC;
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_buscar_apremios_contrato(INTEGER) TO PUBLIC;

-- ============================================
-- SP 6/6: sp_aseo_tipos_aseo_list
-- Tipo: Catalog
-- Descripción: Lista de tipos de aseo para combo
-- ============================================
DROP FUNCTION IF EXISTS public.sp_aseo_tipos_aseo_list();

CREATE OR REPLACE FUNCTION public.sp_aseo_tipos_aseo_list()
RETURNS TABLE (
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT ta.ctrol_aseo::INTEGER,
           ta.tipo_aseo::VARCHAR,
           ta.descripcion::VARCHAR
    FROM ta_16_tipo_aseo ta
    ORDER BY ta.ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION public.sp_aseo_tipos_aseo_list() TO PUBLIC;

-- ============================================
-- FIN DEL ARCHIVO
-- ============================================
