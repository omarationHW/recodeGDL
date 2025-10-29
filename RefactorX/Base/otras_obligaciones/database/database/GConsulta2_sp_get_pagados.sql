-- Stored Procedure: sp_get_pagados
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados de un control
-- Generado para formulario: GConsulta2
-- Fecha: 2025-08-27 16:06:00

CREATE OR REPLACE FUNCTION sp_get_pagados(par_id_datos INTEGER)
RETURNS TABLE (
  id_34_pagos INTEGER,
  id_datos INTEGER,
  periodo TIMESTAMP,
  importe NUMERIC,
  recargo NUMERIC,
  fecha_hora_pago TIMESTAMP,
  id_recaudadora INTEGER,
  caja VARCHAR,
  operacion INTEGER,
  folio_recibo VARCHAR,
  usuario VARCHAR,
  id_stat INTEGER
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
    FROM t34_pagos a
    JOIN t34_status b ON b.id_34_stat = a.id_stat
    WHERE a.id_datos = par_id_datos AND b.cve_stat = 'P'
    ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;