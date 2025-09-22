-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS (EXACTO del archivo original)
-- Archivo: 109_SP_ASEO_SQRPTCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: rpt_contratos
-- Tipo: Report
-- Descripción: Genera el reporte de contratos con filtros dinámicos y clasificación, equivalente a impr_todo en Delphi.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_contratos(
    p_seleccion integer,
    p_ofna integer,
    p_rep integer,
    p_opcion integer,
    p_num_emp integer,
    p_ctrol_aseo integer,
    p_vigencia varchar
)
RETURNS TABLE (
    num_empresa integer,
    ctrol_emp integer,
    tipo_empresa varchar,
    descripcion varchar,
    descripcion_1 varchar,
    representante varchar,
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    tipo_aseo varchar,
    descripcion_2 varchar,
    ctrol_recolec integer,
    cve_recolec varchar,
    descripcion_3 varchar,
    cantidad_recolec smallint,
    domicilio varchar,
    sector varchar,
    ctrol_zona integer,
    zona smallint,
    sub_zona smallint,
    descripcion_4 varchar,
    id_rec smallint,
    recaudadora varchar,
    fecha_hora_alta timestamp,
    status_vigencia varchar,
    aso_mes_oblig date,
    cve varchar,
    usuario integer,
    fecha_hora_baja timestamp
) AS $$
DECLARE
    v_sql text;
BEGIN
    v_sql := 'SELECT A.num_empresa, A.ctrol_emp, B.tipo_empresa, B.descripcion, A.descripcion as descripcion_1, A.representante, '
        || 'C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion as descripcion_2, '
        || 'C.ctrol_recolec, E.cve_recolec, E.descripcion as descripcion_3, C.cantidad_recolec, '
        || 'C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion as descripcion_4, '
        || 'C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja '
        || 'FROM public.ta_16_empresas A '
        || 'JOIN public.ta_16_tipos_emp B ON B.ctrol_emp = A.ctrol_emp '
        || 'JOIN public.ta_16_contratos C ON C.num_empresa = A.num_empresa AND C.ctrol_emp = A.ctrol_emp '
        || 'JOIN public.ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo '
        || 'JOIN public.ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec '
        || 'JOIN public.ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona '
        || 'JOIN public.ta_12_recaudadoras G ON G.id_rec = C.id_rec '
        || 'WHERE 1=1 ';

    IF p_seleccion = 2 THEN
        v_sql := v_sql || ' AND A.num_empresa = ' || p_num_emp;
    ELSE
        v_sql := v_sql || ' AND A.num_empresa > 0';
    END IF;

    IF p_ctrol_aseo = 0 THEN
        v_sql := v_sql || ' AND C.ctrol_aseo <> 0';
    ELSE
        v_sql := v_sql || ' AND C.ctrol_aseo = ' || p_ctrol_aseo;
    END IF;

    IF p_vigencia = 'T' THEN
        v_sql := v_sql || ' AND C.status_vigencia <> ''Z''';
    ELSE
        v_sql := v_sql || ' AND C.status_vigencia = ''' || p_vigencia || '''';
    END IF;

    IF p_ofna <> 0 THEN
        v_sql := v_sql || ' AND C.id_rec = ' || p_ofna;
    ELSE
        v_sql := v_sql || ' AND C.id_rec <> 0';
    END IF;

    -- Clasificación
    IF p_opcion = 1 THEN
        v_sql := v_sql || ' ORDER BY A.num_empresa, C.control_contrato';
    ELSIF p_opcion = 2 THEN
        v_sql := v_sql || ' ORDER BY A.num_empresa, C.num_contrato';
    ELSIF p_opcion = 3 THEN
        v_sql := v_sql || ' ORDER BY A.num_empresa, D.tipo_aseo';
    ELSIF p_opcion = 4 THEN
        v_sql := v_sql || ' ORDER BY A.num_empresa, C.id_rec';
    ELSIF p_opcion = 5 THEN
        v_sql := v_sql || ' ORDER BY A.num_empresa, E.cve_recolec';
    ELSIF p_opcion = 6 THEN
        v_sql := v_sql || ' ORDER BY A.num_empresa, C.status_vigencia';
    ELSIF p_opcion = 7 THEN
        v_sql := v_sql || ' ORDER BY A.num_empresa, C.aso_mes_oblig';
    ELSIF p_opcion = 8 THEN
        v_sql := v_sql || ' ORDER BY A.num_empresa, C.domicilio, C.num_contrato, C.ctrol_aseo';
    END IF;

    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;


-- ============================================

