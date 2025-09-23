-- Stored Procedure: buscar_pagos_locales_por_local
-- Tipo: Report
-- Descripción: Busca pagos de locales por criterios de local
-- Generado para formulario: ConsPagosLocales
-- Fecha: 2025-08-26 23:21:11

CREATE OR REPLACE FUNCTION buscar_pagos_locales_por_local(
  p_oficina smallint,
  p_num_mercado smallint,
  p_categoria smallint,
  p_seccion text,
  p_local integer,
  p_letra_local text,
  p_bloque text,
  p_orden text,
  p_limit integer,
  p_offset integer
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
      || 'WHERE a.oficina = $1 AND a.num_mercado = $2 AND a.categoria = $3 AND a.seccion = $4 AND a.local = $5 '
      || (CASE WHEN p_letra_local IS NULL OR p_letra_local = '' THEN ' AND a.letra_local IS NULL ' ELSE ' AND a.letra_local = $6 ' END)
      || (CASE WHEN p_bloque IS NULL OR p_bloque = '' THEN ' AND a.bloque IS NULL ' ELSE ' AND a.bloque = $7 ' END)
      || ' ORDER BY ' || p_orden || ' LIMIT $8 OFFSET $9';
  RETURN QUERY EXECUTE sql USING p_oficina, p_num_mercado, p_categoria, p_seccion, p_local, p_letra_local, p_bloque, p_limit, p_offset;
END; $$ LANGUAGE plpgsql;