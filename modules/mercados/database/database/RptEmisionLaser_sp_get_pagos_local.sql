-- Stored Procedure: sp_get_pagos_local
-- Tipo: Report
-- Descripción: Obtiene los pagos de un local para un año y periodo.
-- Generado para formulario: RptEmisionLaser
-- Fecha: 2025-08-27 20:48:44

CREATE OR REPLACE FUNCTION sp_get_pagos_local(p_id_local integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
  id_pago_local integer,
  fecha_pago date,
  importe_pago numeric,
  folio varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_pago_local, fecha_pago, importe_pago, folio
  FROM ta_11_pagos_local
  WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;