-- Stored Procedure: rpt_contratos_det_summary
-- Tipo: Report
-- Descripción: Obtiene el resumen de contratos: total, vigentes y cancelados según filtros.
-- Generado para formulario: sQRptContratos_Det
-- Fecha: 2025-08-27 15:28:51

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