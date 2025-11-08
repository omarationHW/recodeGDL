-- Stored Procedure: rpt_pagos_por_contrato
-- Tipo: Report
-- Descripción: Devuelve los pagos por contrato, con los campos requeridos para el reporte, filtrando por control_contrato, status_vigencia = 'P', y uniendo con operaciones y recaudadoras.
-- Generado para formulario: sQRptPagosXContrato
-- Fecha: 2025-08-27 15:35:42

CREATE OR REPLACE FUNCTION rpt_pagos_por_contrato(
    p_control_contrato integer,
    p_contrato integer,
    p_ctrol_aseo integer
)
RETURNS TABLE (
    control_contrato integer,
    aso_mes_pago date,
    ctrol_operacion integer,
    descripcion varchar,
    exedencias smallint,
    importe numeric(18,2),
    status_vigencia varchar(1),
    fecha_hora_pago timestamp,
    id_rec smallint,
    recaudadora varchar,
    caja varchar(1),
    consec_operacion integer,
    folio_rcbo varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.descripcion,
           a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec,
           c.recaudadora, a.caja, a.consec_operacion, a.folio_rcbo
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    JOIN ta_12_recaudadoras c ON c.id_rec = a.id_rec
    WHERE a.control_contrato = p_control_contrato
      AND a.status_vigencia = 'P'
    ORDER BY a.control_contrato, a.aso_mes_pago, a.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;