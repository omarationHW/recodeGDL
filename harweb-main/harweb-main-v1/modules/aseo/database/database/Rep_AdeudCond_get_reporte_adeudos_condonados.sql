-- Stored Procedure: get_reporte_adeudos_condonados
-- Tipo: Report
-- Descripción: Devuelve el reporte de adeudos condonados para un contrato, ordenado por periodo de pago u operación.
-- Generado para formulario: Rep_AdeudCond
-- Fecha: 2025-08-27 15:05:40

CREATE OR REPLACE FUNCTION get_reporte_adeudos_condonados(
    p_control_contrato integer,
    p_opcion smallint
)
RETURNS TABLE (
    control_contrato integer,
    num_contrato integer,
    ctrol_aseo integer,
    tipo_aseo varchar(1),
    descripcion varchar(80),
    ctrol_recolec integer,
    cve_recolec varchar(20),
    descripcion_1 varchar(80),
    cantidad_recolec smallint,
    domicilio varchar(255),
    sector varchar(50),
    ctrol_zona integer,
    zona smallint,
    sub_zona smallint,
    descripcion_2 varchar(80),
    id_rec smallint,
    recaudadora varchar(80),
    fecha_hora_alta timestamp,
    status_vigencia varchar(1),
    aso_mes_oblig date,
    cve varchar(20),
    usuario integer,
    fecha_hora_baja timestamp,
    control_contrato_1 integer,
    aso_mes_pago date,
    ctrol_operacion integer,
    cve_operacion varchar(20),
    descripcion_3 varchar(80),
    importe numeric,
    status_vigencia_1 varchar(1),
    fecha_hora_pago timestamp,
    folio_rcbo varchar(50),
    exedencias smallint
) AS $$
BEGIN
    RETURN QUERY
    SELECT C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion,
           C.ctrol_recolec, E.cve_recolec, E.descripcion, C.cantidad_recolec,
           C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion,
           C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig,
           C.cve, C.usuario, C.fecha_hora_baja,
           H.control_contrato, H.aso_mes_pago, H.ctrol_operacion, I.cve_operacion, I.descripcion,
           H.importe, H.status_vigencia, H.fecha_hora_pago, H.folio_rcbo, H.exedencias
    FROM ta_16_pagos H
    JOIN ta_16_contratos C ON C.control_contrato = H.control_contrato
    JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
    JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
    JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
    JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
    JOIN ta_16_operacion I ON I.ctrol_operacion = H.ctrol_operacion
    WHERE H.control_contrato = p_control_contrato
      AND H.status_vigencia = 'S'
    ORDER BY
      CASE WHEN p_opcion = 1 THEN H.aso_mes_pago END,
      CASE WHEN p_opcion = 1 THEN I.cve_operacion END,
      CASE WHEN p_opcion = 2 THEN I.cve_operacion END,
      CASE WHEN p_opcion = 2 THEN H.aso_mes_pago END;
END;
$$ LANGUAGE plpgsql;