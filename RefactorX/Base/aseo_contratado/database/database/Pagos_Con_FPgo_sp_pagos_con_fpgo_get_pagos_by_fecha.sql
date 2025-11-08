-- Stored Procedure: sp_pagos_con_fpgo_get_pagos_by_fecha
-- Tipo: Report
-- Descripción: Obtiene todos los pagos realizados en una fecha específica (por fecha_hora_pago, status_vigencia = 'P')
-- Generado para formulario: Pagos_Con_FPgo
-- Fecha: 2025-08-27 15:02:16

CREATE OR REPLACE FUNCTION sp_pagos_con_fpgo_get_pagos_by_fecha(p_fecha DATE)
RETURNS TABLE (
    control_contrato INTEGER,
    aso_mes_pago VARCHAR,
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
    SELECT
        a.control_contrato,
        to_char(a.aso_mes_pago, 'YYYY-MM') as aso_mes_pago,
        a.ctrol_operacion,
        b.descripcion,
        a.exedencias,
        a.importe,
        a.status_vigencia,
        a.fecha_hora_pago,
        a.id_rec,
        c.recaudadora,
        a.caja,
        a.consec_operacion,
        a.folio_rcbo
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    JOIN ta_12_recaudadoras c ON c.id_rec = a.id_rec
    WHERE DATE(a.fecha_hora_pago) = p_fecha
      AND a.status_vigencia = 'P'
    ORDER BY a.control_contrato, a.aso_mes_pago, a.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;