-- Stored Procedure: get_pagos_loc_grl
-- Tipo: Report
-- Descripción: Devuelve los pagos de locales de un mercado y recaudadora en un rango de fechas.
-- Generado para formulario: PagosLocGrl
-- Fecha: 2025-08-27 00:26:11

CREATE OR REPLACE FUNCTION get_pagos_loc_grl(
  rec_id smallint,
  mercado_id smallint,
  fecha_desde date,
  fecha_hasta date
)
RETURNS TABLE(
  num_mercado smallint,
  seccion varchar,
  local integer,
  letra_local varchar,
  bloque varchar,
  axo smallint,
  periodo smallint,
  fecha_pago date,
  oficina_pago smallint,
  caja_pago varchar,
  operacion_pago integer,
  importe_pago numeric,
  folio varchar,
  fecha_modificacion varchar,
  usuario varchar,
  fecha_emision date,
  folio_1 integer,
  requerimientos varchar,
  id_local integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.num_mercado, a.seccion, a.local, a.letra_local, a.bloque,
    b.axo, b.periodo, b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago, b.importe_pago, b.folio,
    to_char(b.fecha_modificacion, 'YYYY-MM-DD HH24:MI:SS') as fecha_modificacion,
    c.usuario,
    d.fecha_emision, d.folio as folio_1,
    (
      SELECT string_agg('(' || p.ayo || '-' || p.periodo || ')', ' ')
      FROM ta_15_periodos p WHERE p.control_otr = a.id_local
    ) as requerimientos,
    a.id_local
  FROM ta_11_locales a
  JOIN ta_11_pagos_local b ON b.id_local = a.id_local
  JOIN ta_12_passwords c ON c.id_usuario = b.id_usuario
  LEFT JOIN ta_15_apremios d ON d.modulo = 11 AND d.control_otr = b.id_local AND d.vigencia = '2' AND d.fecha_pago = b.fecha_pago AND d.recaudadora = b.oficina_pago AND d.caja = b.caja_pago AND d.operacion = b.operacion_pago
  WHERE a.oficina = rec_id
    AND a.num_mercado = mercado_id
    AND b.fecha_pago BETWEEN fecha_desde AND fecha_hasta
  ORDER BY a.seccion, a.local, a.letra_local, a.bloque, b.fecha_pago, b.axo, b.periodo, d.fecha_emision, d.folio;
END;
$$ LANGUAGE plpgsql;