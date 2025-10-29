-- Stored Procedure: get_pagados_by_concesion
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados (status P) para un local/concesión.
-- Generado para formulario: RConsulta
-- Fecha: 2025-08-28 13:38:15

CREATE OR REPLACE FUNCTION get_pagados_by_concesion(p_id_34_datos INTEGER)
RETURNS TABLE(
    id_34_pagos INTEGER,
    id_datos INTEGER,
    periodo DATE,
    importe NUMERIC,
    recargo NUMERIC,
    fecha_hora_pago TIMESTAMP,
    id_recaudadora INTEGER,
    caja TEXT,
    operacion INTEGER,
    folio_recibo TEXT,
    usuario TEXT,
    id_stat INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago,
           a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = p_id_34_datos AND b.cve_stat = 'P';
END;
$$ LANGUAGE plpgsql;