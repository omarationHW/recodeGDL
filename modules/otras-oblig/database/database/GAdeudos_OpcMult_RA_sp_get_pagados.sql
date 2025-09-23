-- Stored Procedure: sp_get_pagados
-- Tipo: Report
-- Descripción: Obtiene los pagos realizados para un control dado.
-- Generado para formulario: GAdeudos_OpcMult_RA
-- Fecha: 2025-08-28 13:01:07

CREATE OR REPLACE FUNCTION sp_get_pagados(p_Control integer)
RETURNS TABLE(
  id_34_pagos integer,
  id_datos integer,
  periodo timestamp,
  importe numeric,
  recargo numeric,
  fecha_hora_pago timestamp,
  id_recaudadora integer,
  caja text,
  operacion integer,
  folio_recibo text,
  usuario text,
  id_stat integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_34_pagos, a.id_datos, a.periodo, a.importe, a.recargo, a.fecha_hora_pago, a.id_recaudadora, a.caja, a.operacion, a.folio_recibo, a.usuario, a.id_stat
  FROM t34_pagos a
  JOIN t34_status b ON b.id_34_stat = a.id_stat AND b.cve_stat = 'P'
  WHERE a.id_datos = p_Control
  ORDER BY a.periodo;
END;
$$ LANGUAGE plpgsql;