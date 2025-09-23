-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sQRptAdeudosVenc
-- Generado: 2025-08-27 15:24:46
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_get_dia_limite
-- Tipo: Catalog
-- Descripción: Obtiene el día límite para el mes dado de la tabla ta_16_Dia_Limite.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dia_limite(p_mes integer)
RETURNS TABLE(mes smallint, dia smallint) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, dia FROM ta_16_dia_limite WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_empresa
-- Tipo: Catalog
-- Descripción: Obtiene los datos de la empresa por num_empresa y ctrol_emp.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_empresa(p_num_empresa integer, p_ctrol_emp integer)
RETURNS TABLE(num_empresa integer, ctrol_emp integer, descripcion varchar, representante varchar) AS $$
BEGIN
    RETURN QUERY
    SELECT num_empresa, ctrol_emp, descripcion, representante
    FROM ta_16_empresas
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_get_adeudos_vencidos
-- Tipo: Report
-- Descripción: Obtiene los adeudos vencidos para un contrato, considerando el día límite y periodo opcional.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_adeudos_vencidos(
    p_control_contrato integer,
    p_dia_limite smallint,
    p_aso_hoy smallint,
    p_mes_hoy smallint,
    p_periodo varchar
)
RETURNS TABLE(
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    tipo_aseo varchar,
    descripcion varchar,
    num_empresa integer,
    ctrol_emp integer,
    ctrol_recolec integer,
    cve_recolec varchar,
    descripcion_1 varchar,
    cantidad_recolec smallint,
    domicilio varchar,
    sector varchar,
    ctrol_zona integer,
    zona smallint,
    sub_zona smallint,
    descripcion_2 varchar,
    id_rec smallint,
    recaudadora varchar,
    fecha_hora_alta timestamp,
    status_vigencia varchar,
    aso_mes_oblig date,
    cve varchar,
    usuario integer,
    fecha_hora_baja timestamp,
    control_contrato_1 integer,
    aso_mes_pago date,
    ctrol_operacion integer,
    cve_operacion varchar,
    descripcion_3 varchar,
    importe numeric,
    status_vigencia_1 varchar,
    fecha_hora_pago timestamp,
    folio_rcbo varchar,
    exedencias smallint
) AS $$
DECLARE
    v_fecha_hoy date := CURRENT_DATE;
    v_sql text;
BEGIN
    v_sql := 'SELECT C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion, '
        || 'C.num_empresa, C.ctrol_emp, C.ctrol_recolec, E.cve_recolec, E.descripcion as descripcion_1, '
        || 'C.cantidad_recolec, C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion as descripcion_2, '
        || 'C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja, '
        || 'H.control_contrato as control_contrato_1, H.aso_mes_pago, H.ctrol_operacion, I.cve_operacion, I.descripcion as descripcion_3, '
        || 'H.importe, H.status_vigencia as status_vigencia_1, H.fecha_hora_pago, H.folio_rcbo, H.exedencias '
        || 'FROM ta_16_pagos H '
        || 'JOIN ta_16_contratos C ON C.control_contrato = H.control_contrato '
        || 'JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo '
        || 'JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec '
        || 'JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona '
        || 'JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec '
        || 'JOIN ta_16_operacion I ON I.ctrol_operacion = H.ctrol_operacion '
        || 'WHERE H.control_contrato = ' || p_control_contrato || ' ';

    IF (EXTRACT(DAY FROM v_fecha_hoy) > p_dia_limite) THEN
        v_sql := v_sql || 'AND H.aso_mes_pago <= ''' || p_aso_hoy || '-' || LPAD(p_mes_hoy::text,2,'0') || ''' ';
    ELSE
        v_sql := v_sql || 'AND H.aso_mes_pago < ''' || p_aso_hoy || '-' || LPAD(p_mes_hoy::text,2,'0') || ''' ';
    END IF;

    v_sql := v_sql || 'AND H.status_vigencia = ''V'' ';

    IF (p_periodo IS NOT NULL AND TRIM(p_periodo) <> '') THEN
        v_sql := v_sql || 'UNION ALL '
            || 'SELECT C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion, '
            || 'C.num_empresa, C.ctrol_emp, C.ctrol_recolec, E.cve_recolec, E.descripcion as descripcion_1, '
            || 'C.cantidad_recolec, C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion as descripcion_2, '
            || 'C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja, '
            || 'H.control_contrato as control_contrato_1, H.aso_mes_pago, H.ctrol_operacion, I.cve_operacion, I.descripcion as descripcion_3, '
            || 'H.importe, H.status_vigencia as status_vigencia_1, H.fecha_hora_pago, H.folio_rcbo, H.exedencias '
            || 'FROM ta_16_pagos H '
            || 'JOIN ta_16_contratos C ON C.control_contrato = H.control_contrato '
            || 'JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo '
            || 'JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec '
            || 'JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona '
            || 'JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec '
            || 'JOIN ta_16_operacion I ON I.ctrol_operacion = H.ctrol_operacion '
            || 'WHERE H.control_contrato = ' || p_control_contrato || ' ';
        IF (EXTRACT(DAY FROM v_fecha_hoy) > p_dia_limite) THEN
            v_sql := v_sql || 'AND H.aso_mes_pago BETWEEN ''' || p_aso_hoy || '-' || LPAD((p_mes_hoy+1)::text,2,'0') || ''' AND ''' || p_periodo || ''' ';
        ELSE
            v_sql := v_sql || 'AND H.aso_mes_pago BETWEEN ''' || p_aso_hoy || '-' || LPAD(p_mes_hoy::text,2,'0') || ''' AND ''' || p_periodo || ''' ';
        END IF;
        v_sql := v_sql || 'AND H.status_vigencia = ''V'' ';
    END IF;

    v_sql := v_sql || 'ORDER BY 29, 27';

    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_get_importe_recargo
-- Tipo: CRUD
-- Descripción: Calcula el importe de recargo para un adeudo vencido, según la lógica del formulario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_importe_recargo(
    p_importe numeric,
    p_ctrol_operacion integer,
    p_aso_mes_pago date,
    p_aso_hoy smallint,
    p_mes_hoy smallint
)
RETURNS TABLE(importe_recargo numeric) AS $$
DECLARE
    year_pago integer;
    mes_pago integer;
    year_ade integer;
    mes_ade integer;
    aso_ade integer;
    mes_ade_final integer;
    aso_hoy integer := p_aso_hoy;
    mes_hoy integer := p_mes_hoy;
    sum_recargo numeric := 0;
    fecha_pago text;
    fecha_hoy text;
BEGIN
    year_pago := EXTRACT(YEAR FROM p_aso_mes_pago);
    mes_pago := EXTRACT(MONTH FROM p_aso_mes_pago);
    aso_ade := year_pago;
    mes_ade_final := mes_pago;
    IF p_ctrol_operacion <> 6 THEN
        IF mes_ade_final = 11 THEN
            aso_ade := aso_ade + 1;
            mes_ade_final := 1;
        ELSIF mes_ade_final = 12 THEN
            aso_ade := aso_ade + 1;
            mes_ade_final := 2;
        ELSIF mes_ade_final >= 1 AND mes_ade_final <= 10 THEN
            mes_ade_final := mes_ade_final + 2;
        END IF;
    END IF;
    fecha_pago := aso_ade::text || '-' || LPAD(mes_ade_final::text,2,'0');
    fecha_hoy := aso_hoy::text || '-' || LPAD(mes_hoy::text,2,'0');
    SELECT COALESCE(SUM(porc_recargo),0) INTO sum_recargo
    FROM ta_16_recargos
    WHERE aso_mes_recargo BETWEEN fecha_pago AND fecha_hoy;
    RETURN QUERY SELECT ROUND((p_importe * sum_recargo) / 100, 2);
END;
$$ LANGUAGE plpgsql;

-- ============================================

