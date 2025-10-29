-- Stored Procedure: buscar_pagos_locales_por_fecha
-- Tipo: Report
-- Descripción: Busca pagos de locales por fecha de pago y otros filtros
-- Generado para formulario: ConsPagosLocales
-- Fecha: 2025-08-26 23:21:11

CREATE OR REPLACE FUNCTION buscar_pagos_locales_por_fecha(
  p_fecha_pago date,
  p_oficina_pago smallint,
  p_caja_pago text,
  p_operacion_pago integer,
  p_orden text,
  p_limit integer,
  p_offset integer,
  p_usuario_id integer
) RETURNS SETOF RECORD AS $$
DECLARE
  sql text;
BEGIN
  sql := 'SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, '
      || 'b.axo, b.periodo, b.fecha_pago, b.oficina_pago, b.caja_pago, b.operacion_pago, b.importe_pago, b.folio, '
      || 'b.fecha_modificacion as fecha_modificacion_1, c.usuario '
      || 'FROM ta_11_locales a '
      || 'JOIN ta_11_pagos_local b ON a.id_local = b.id_local '
      || 'JOIN ta_12_passwords c ON b.id_usuario = c.id_usuario '
      || 'WHERE b.fecha_pago = $1 AND b.oficina_pago = $2 AND b.caja_pago = $3 AND b.operacion_pago = $4 '
      || 'ORDER BY ' || p_orden || ' LIMIT $5 OFFSET $6';
  RETURN QUERY EXECUTE sql USING p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_limit, p_offset;
END; $$ LANGUAGE plpgsql;