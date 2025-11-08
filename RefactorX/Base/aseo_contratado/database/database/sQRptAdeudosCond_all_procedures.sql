-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sQRptAdeudosCond
-- Generado: 2025-08-27 15:22:49
-- Total SPs: 1
-- ============================================

-- SP 1/1: rpt_adeudos_condonados
-- Tipo: Report
-- Descripción: Devuelve el reporte de adeudos condonados de aseo contratado para un contrato y opción de clasificación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_adeudos_condonados(p_control_contrato integer, p_opcion smallint)
RETURNS TABLE(
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    tipo_aseo varchar(1),
    descripcion varchar(80),
    ctrol_recolec integer,
    cve_recolec varchar(1),
    descripcion_1 varchar(80),
    cantidad_recolec smallint,
    domicilio varchar(80),
    sector varchar(1),
    ctrol_zona integer,
    zona smallint,
    sub_zona smallint,
    descripcion_2 varchar(80),
    id_rec smallint,
    recaudadora varchar(50),
    fecha_hora_alta timestamp,
    status_vigencia varchar(1),
    aso_mes_oblig date,
    cve varchar(1),
    usuario integer,
    fecha_hora_baja timestamp,
    control_contrato_1 integer,
    aso_mes_pago date,
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion_3 varchar(80),
    importe numeric(18,2),
    status_vigencia_1 varchar(1),
    fecha_hora_pago timestamp,
    folio_rcbo varchar(10),
    exedencias smallint
) AS $$
DECLARE
    v_sql text;
BEGIN
    v_sql :=
    'SELECT C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion, '
    ||'C.ctrol_recolec, E.cve_recolec, E.descripcion as descripcion_1, C.cantidad_recolec, '
    ||'C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion as descripcion_2, '
    ||'C.id_rec, G.recaudadora, '
    ||'C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja, '
    ||'H.control_contrato as control_contrato_1, H.aso_mes_pago, H.ctrol_operacion, I.cve_operacion, I.descripcion as descripcion_3, H.importe, H.status_vigencia as status_vigencia_1, '
    ||'H.fecha_hora_pago, H.folio_rcbo, H.exedencias '
    ||'FROM ta_16_pagos H '
    ||'JOIN ta_16_contratos C ON C.control_contrato = H.control_contrato '
    ||'JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo '
    ||'JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec '
    ||'JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona '
    ||'JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec '
    ||'JOIN ta_16_operacion I ON I.ctrol_operacion = H.ctrol_operacion '
    ||'WHERE H.control_contrato = $1 AND H.status_vigencia = ''S'' ';
    IF p_opcion = 1 THEN
        v_sql := v_sql || 'ORDER BY H.aso_mes_pago, I.cve_operacion';
    ELSE
        v_sql := v_sql || 'ORDER BY I.cve_operacion, H.aso_mes_pago';
    END IF;
    RETURN QUERY EXECUTE v_sql USING p_control_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================

