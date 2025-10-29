-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sQRptContratos_Det
-- Generado: 2025-08-27 15:28:51
-- Total SPs: 2
-- ============================================

-- SP 1/2: rpt_contratos_det
-- Tipo: Report
-- Descripción: Obtiene el detalle de contratos según filtros de vigencia, recaudadora, clasificación y empleado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_contratos_det(
    p_vigencia VARCHAR DEFAULT 'T',
    p_ofna INTEGER DEFAULT 0,
    p_opcion INTEGER DEFAULT 1,
    p_num_emp INTEGER DEFAULT NULL
)
RETURNS TABLE (
    control_contrato INTEGER,
    num_contrato INTEGER,
    ctrol_aseo INTEGER,
    tipo_aseo VARCHAR,
    descripcion VARCHAR,
    ctrol_recolec INTEGER,
    cve_recolec VARCHAR,
    descripcion_1 VARCHAR,
    cantidad_recolec SMALLINT,
    domicilio VARCHAR,
    sector VARCHAR,
    ctrol_zona INTEGER,
    zona SMALLINT,
    sub_zona SMALLINT,
    descripcion_2 VARCHAR,
    id_rec SMALLINT,
    recaudadora VARCHAR,
    fecha_hora_alta TIMESTAMP,
    status_vigencia VARCHAR,
    aso_mes_oblig TIMESTAMP,
    cve VARCHAR,
    usuario INTEGER,
    fecha_hora_baja TIMESTAMP
) AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion, '
        || 'C.ctrol_recolec, E.cve_recolec, E.descripcion as descripcion_1, C.cantidad_recolec, '
        || 'C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion as descripcion_2, '
        || 'C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja '
        || 'FROM ta_16_contratos C '
        || 'JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo '
        || 'JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec '
        || 'JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona '
        || 'JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec '
        || 'WHERE C.num_contrato <> 0 ';
    IF p_vigencia = 'T' THEN
        v_sql := v_sql || 'AND C.status_vigencia <> ''Z'' ';
    ELSE
        v_sql := v_sql || 'AND C.status_vigencia = ''' || p_vigencia || ''' ';
    END IF;
    IF p_ofna <> 0 THEN
        v_sql := v_sql || 'AND C.id_rec = ' || p_ofna || ' ';
    ELSE
        v_sql := v_sql || 'AND C.id_rec <> 0 ';
    END IF;
    -- Opciones de ordenamiento
    IF p_opcion = 1 THEN
        v_sql := v_sql || 'ORDER BY C.control_contrato ';
    ELSIF p_opcion = 2 THEN
        v_sql := v_sql || 'ORDER BY C.num_contrato, D.tipo_aseo ';
    ELSIF p_opcion = 3 THEN
        v_sql := v_sql || 'ORDER BY D.tipo_aseo, C.num_contrato ';
    ELSIF p_opcion = 4 THEN
        v_sql := v_sql || 'ORDER BY C.id_rec ';
    ELSIF p_opcion = 5 THEN
        v_sql := v_sql || 'ORDER BY E.cve_recolec ';
    ELSIF p_opcion = 6 THEN
        v_sql := v_sql || 'ORDER BY C.status_vigencia ';
    ELSIF p_opcion = 7 THEN
        v_sql := v_sql || 'ORDER BY C.aso_mes_oblig ';
    ELSIF p_opcion = 8 THEN
        v_sql := v_sql || 'ORDER BY C.domicilio, C.num_contrato, C.ctrol_aseo ';
    END IF;
    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: rpt_contratos_det_summary
-- Tipo: Report
-- Descripción: Obtiene el resumen de contratos: total, vigentes y cancelados según filtros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_contratos_det_summary(
    p_vigencia VARCHAR DEFAULT 'T',
    p_ofna INTEGER DEFAULT 0,
    p_opcion INTEGER DEFAULT 1,
    p_num_emp INTEGER DEFAULT NULL
)
RETURNS TABLE (
    total_contratos INTEGER,
    vigentes INTEGER,
    cancelados INTEGER
) AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT COUNT(*) as total_contratos, '
        || 'SUM(CASE WHEN C.status_vigencia = ''V'' THEN 1 ELSE 0 END) as vigentes, '
        || 'SUM(CASE WHEN C.status_vigencia = ''C'' THEN 1 ELSE 0 END) as cancelados '
        || 'FROM ta_16_contratos C '
        || 'JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo '
        || 'JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec '
        || 'JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona '
        || 'JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec '
        || 'WHERE C.num_contrato <> 0 ';
    IF p_vigencia = 'T' THEN
        v_sql := v_sql || 'AND C.status_vigencia <> ''Z'' ';
    ELSE
        v_sql := v_sql || 'AND C.status_vigencia = ''' || p_vigencia || ''' ';
    END IF;
    IF p_ofna <> 0 THEN
        v_sql := v_sql || 'AND C.id_rec = ' || p_ofna || ' ';
    ELSE
        v_sql := v_sql || 'AND C.id_rec <> 0 ';
    END IF;
    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

