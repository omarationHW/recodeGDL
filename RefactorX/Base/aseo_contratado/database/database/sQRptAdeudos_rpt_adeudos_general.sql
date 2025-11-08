-- Stored Procedure: rpt_adeudos_general
-- Tipo: Report
-- Descripción: Reporte general de adeudos de aseo contratado, con filtros y clasificación dinámica.
-- Generado para formulario: sQRptAdeudos
-- Fecha: 2025-08-27 15:21:07

-- SP: rpt_adeudos_general
-- Parámetros:
--   sel_emp INT, sel_cont INT, ofna INT, opcion INT, num_emp INT, num_cont INT, sel_ctrol_aseo INT, vig_cont TEXT, vig_adeudos TEXT
-- Retorna: SETOF RECORD con todos los campos requeridos para el reporte
CREATE OR REPLACE FUNCTION rpt_adeudos_general(
    sel_emp INT,
    sel_cont INT,
    ofna INT,
    opcion INT,
    num_emp INT,
    num_cont INT,
    sel_ctrol_aseo INT,
    vig_cont TEXT,
    vig_adeudos TEXT
)
RETURNS TABLE (
    num_empresa INT,
    ctrol_emp INT,
    tipo_empresa TEXT,
    descripcion TEXT,
    descripcion_1 TEXT,
    representante TEXT,
    control_contrato INT,
    num_contrato INT,
    ctrol_aseo INT,
    tipo_aseo TEXT,
    descripcion_2 TEXT,
    ctrol_recolec INT,
    cve_recolec TEXT,
    descripcion_3 TEXT,
    cantidad_recolec SMALLINT,
    domicilio TEXT,
    sector TEXT,
    ctrol_zona INT,
    zona SMALLINT,
    sub_zona SMALLINT,
    descripcion_4 TEXT,
    id_rec SMALLINT,
    recaudadora TEXT,
    fecha_hora_alta TIMESTAMP,
    status_vigencia TEXT,
    aso_mes_oblig DATE,
    cve TEXT,
    usuario INT,
    fecha_hora_baja TIMESTAMP,
    control_contrato_1 INT,
    aso_mes_pago DATE,
    ctrol_operacion INT,
    cve_operacion TEXT,
    descripcion_5 TEXT,
    importe NUMERIC,
    status_vigencia_1 TEXT,
    fecha_hora_pago TIMESTAMP,
    id_rec_1 SMALLINT,
    caja TEXT,
    consec_operacion INT,
    folio_rcbo TEXT,
    usuario_1 INT,
    exedencias SMALLINT
) AS $$
DECLARE
    year_now INT := EXTRACT(YEAR FROM CURRENT_DATE);
    month_now INT := EXTRACT(MONTH FROM CURRENT_DATE);
    order_by TEXT;
BEGIN
    -- Determinar el ORDER BY según opcion
    order_by := CASE opcion
        WHEN 1 THEN 'C.Num_Contrato, h.Aso_mes_pago, i.cve_operacion'
        WHEN 2 THEN 'C.Num_Contrato, i.cve_operacion'
        WHEN 3 THEN 'C.Num_Contrato, h.Status_Vigencia, i.cve_operacion'
        WHEN 4 THEN 'C.Num_Contrato, h.Fecha_hora_pago, i.cve_operacion'
        WHEN 5 THEN 'C.Num_Contrato, h.id_rec, i.cve_operacion'
        WHEN 6 THEN 'C.Num_Contrato, h.Caja, i.cve_operacion'
        ELSE 'C.Num_Contrato, h.Aso_mes_pago, i.cve_operacion'
    END;

    RETURN QUERY EXECUTE format('
        SELECT A.Num_empresa, A.Ctrol_emp, B.Tipo_empresa, B.Descripcion, A.Descripcion AS descripcion_1, A.Representante,
            C.Control_contrato, C.Num_contrato, C.Ctrol_aseo, D.Tipo_aseo, D.Descripcion AS descripcion_2,
            C.Ctrol_recolec, E.Cve_recolec, E.Descripcion AS descripcion_3, C.Cantidad_recolec,
            C.Domicilio, C.Sector, C.Ctrol_zona, F.zona, F.sub_zona, F.Descripcion AS descripcion_4,
            C.Id_rec, G.Recaudadora,
            C.Fecha_hora_alta, C.Status_vigencia, C.Aso_mes_oblig, C.Cve, C.Usuario, C.Fecha_hora_baja,
            h.control_contrato AS control_contrato_1, h.aso_mes_pago, h.ctrol_operacion, i.cve_operacion, i.descripcion AS descripcion_5, h.importe, h.status_vigencia AS status_vigencia_1,
            h.fecha_hora_pago, h.id_rec AS id_rec_1, h.caja, h.consec_operacion, h.folio_rcbo, h.usuario AS usuario_1, h.exedencias
        FROM ta_16_empresas A
        JOIN ta_16_tipos_emp B ON B.Ctrol_emp = A.Ctrol_emp
        JOIN ta_16_contratos C ON C.Num_empresa = A.Num_empresa AND C.Ctrol_emp = A.Ctrol_emp
        JOIN ta_16_tipo_aseo D ON D.Ctrol_aseo = C.Ctrol_aseo
        JOIN ta_16_unidades E ON E.Ctrol_recolec = C.Ctrol_recolec
        JOIN ta_16_zonas F ON F.Ctrol_zona = C.Ctrol_zona
        JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
        JOIN ta_16_pagos H ON H.control_contrato = C.control_contrato
        JOIN ta_16_operacion I ON I.ctrol_operacion = H.ctrol_operacion
        WHERE 1=1
        %s -- Filtros empresa
        %s -- Filtros contrato
        %s -- Filtros aseo
        %s -- Filtros vigencia contrato
        %s -- Filtros recaudadora
        %s -- Filtros vigencia adeudos
        %s -- Filtros fecha adeudos vencidos
        ORDER BY %s',
        -- Empresa
        CASE WHEN sel_emp = 2 THEN format('AND A.Num_empresa = %s', num_emp) ELSE 'AND A.Num_empresa <> 0' END,
        -- Contrato
        CASE WHEN sel_cont = 2 THEN format('AND C.Num_contrato = %s', num_cont) ELSE 'AND C.Num_contrato <> 0' END,
        -- Tipo de aseo
        CASE WHEN sel_ctrol_aseo > 0 THEN format('AND C.Ctrol_aseo = %s', sel_ctrol_aseo) ELSE 'AND C.Ctrol_aseo <> 0' END,
        -- Vigencia contrato
        CASE WHEN vig_cont <> 'T' THEN format('AND C.Status_vigencia = %L', vig_cont) ELSE 'AND C.Status_vigencia <> ''Z''' END,
        -- Recaudadora
        CASE WHEN ofna <> 0 THEN format('AND C.Id_rec = %s', ofna) ELSE 'AND C.Id_rec <> 0' END,
        -- Vigencia adeudos
        CASE WHEN vig_adeudos = 'T' THEN 'AND h.status_vigencia <> ''Z''' ELSE format('AND h.status_vigencia = %L', vig_adeudos) END,
        -- Fecha adeudos vencidos
        format('AND to_char(h.aso_mes_pago, ''YYYY-MM'') <= %L', concat(year_now, '-', lpad(month_now::text,2,'0'))),
        order_by
    );
END;
$$ LANGUAGE plpgsql;
