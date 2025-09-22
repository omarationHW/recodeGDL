-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTADEUDOSVENC (EXACTO del archivo original)
-- Archivo: 104_SP_ASEO_SQRPTADEUDOSVENC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_get_dia_limite
-- Tipo: Catalog
-- Descripción: Obtiene el día límite para el mes dado de la tabla ta_16_Dia_Limite.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_dia_limite(p_mes integer)
RETURNS TABLE(mes smallint, dia smallint) AS $$
BEGIN
    RETURN QUERY
    SELECT mes, dia FROM public.ta_16_dia_limite WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTADEUDOSVENC (EXACTO del archivo original)
-- Archivo: 104_SP_ASEO_SQRPTADEUDOSVENC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
        || 'FROM public.ta_16_pagos H '
        || 'JOIN public.ta_16_contratos C ON C.control_contrato = H.control_contrato '
        || 'JOIN public.ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo '
        || 'JOIN public.ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec '
        || 'JOIN public.ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona '
        || 'JOIN public.ta_12_recaudadoras G ON G.id_rec = C.id_rec '
        || 'JOIN public.ta_16_operacion I ON I.ctrol_operacion = H.ctrol_operacion '
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
            || 'FROM public.ta_16_pagos H '
            || 'JOIN public.ta_16_contratos C ON C.control_contrato = H.control_contrato '
            || 'JOIN public.ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo '
            || 'JOIN public.ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec '
            || 'JOIN public.ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona '
            || 'JOIN public.ta_12_recaudadoras G ON G.id_rec = C.id_rec '
            || 'JOIN public.ta_16_operacion I ON I.ctrol_operacion = H.ctrol_operacion '
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTADEUDOSVENC (EXACTO del archivo original)
-- Archivo: 104_SP_ASEO_SQRPTADEUDOSVENC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

