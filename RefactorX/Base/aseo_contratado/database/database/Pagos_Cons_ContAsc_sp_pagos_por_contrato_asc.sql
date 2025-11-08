-- Stored Procedure: sp_pagos_por_contrato_asc
-- Tipo: Report
-- Descripción: Devuelve los pagos del contrato (vigencia = 'P') ordenados por periodo y operación.
-- Generado para formulario: Pagos_Cons_ContAsc
-- Fecha: 2025-08-27 15:00:04

CREATE OR REPLACE FUNCTION sp_pagos_por_contrato_asc(
    p_control_contrato INTEGER
)
RETURNS TABLE (
    control_contrato INTEGER,
    aso_mes_pago DATE,
    ctrol_operacion INTEGER,
    descripcion VARCHAR,
    exedencias SMALLINT,
    importe NUMERIC,
    status_vigencia VARCHAR,
    fecha_hora_pago TIMESTAMP,
    id_rec SMALLINT,
    recaudadora VARCHAR,
    caja VARCHAR,
    consec_operacion INTEGER,
    folio_rcbo VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.descripcion,
           a.exedencias, a.importe, a.status_vigencia, a.fecha_hora_pago, a.id_rec, c.recaudadora,
           a.caja, a.consec_operacion, a.folio_rcbo
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    JOIN ta_12_recaudadoras c ON c.id_rec = a.id_rec
    WHERE a.control_contrato = p_control_contrato
      AND a.status_vigencia = 'P'
    ORDER BY a.control_contrato, a.aso_mes_pago, a.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;