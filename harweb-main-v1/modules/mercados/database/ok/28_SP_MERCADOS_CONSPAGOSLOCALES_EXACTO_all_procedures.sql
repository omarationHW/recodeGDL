-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ConsPagosLocales
-- Generado: 2025-08-26 23:21:11
-- Total SPs: 6
-- ============================================

-- SP 1/6: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Obtiene la lista de recaudadoras
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_recaudadoras() RETURNS TABLE(id_rec smallint, recaudadora text) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora FROM public.ta_12_recaudadoras ORDER BY id_rec;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: get_secciones
-- Tipo: Catalog
-- Descripción: Obtiene la lista de secciones
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_secciones() RETURNS TABLE(seccion text, descripcion text) AS $$
BEGIN
  RETURN QUERY SELECT seccion, descripcion FROM public.ta_11_secciones ORDER BY seccion;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: get_mercados_by_oficina
-- Tipo: Catalog
-- Descripción: Obtiene mercados por oficina
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_mercados_by_oficina(p_oficina smallint) RETURNS TABLE(num_mercado_nvo smallint, descripcion text, categoria smallint) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion, categoria FROM public.ta_11_mercados WHERE oficina = p_oficina ORDER BY num_mercado_nvo;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: get_cajas_by_oficina
-- Tipo: Catalog
-- Descripción: Obtiene cajas por oficina
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_cajas_by_oficina(p_oficina smallint) RETURNS TABLE(caja text) AS $$
BEGIN
  RETURN QUERY SELECT caja FROM public.ta_12_operaciones WHERE id_rec = p_oficina ORDER BY caja;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: buscar_pagos_locales_por_local
-- Tipo: Report
-- Descripción: Busca pagos de locales por criterios de local
-- --------------------------------------------

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
      || 'FROM public.ta_11_locales a '
      || 'JOIN public.ta_11_pagos_local b ON a.id_local = b.id_local '
      || 'JOIN public.ta_12_passwords c ON b.id_usuario = c.id_usuario '
      || 'WHERE a.oficina = $1 AND a.num_mercado = $2 AND a.categoria = $3 AND a.seccion = $4 AND a.local = $5 '
      || (CASE WHEN p_letra_local IS NULL OR p_letra_local = '' THEN ' AND a.letra_local IS NULL ' ELSE ' AND a.letra_local = $6 ' END)
      || (CASE WHEN p_bloque IS NULL OR p_bloque = '' THEN ' AND a.bloque IS NULL ' ELSE ' AND a.bloque = $7 ' END)
      || ' ORDER BY ' || p_orden || ' LIMIT $8 OFFSET $9';
  RETURN QUERY EXECUTE sql USING p_oficina, p_num_mercado, p_categoria, p_seccion, p_local, p_letra_local, p_bloque, p_limit, p_offset;
END; $$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: buscar_pagos_locales_por_fecha
-- Tipo: Report
-- Descripción: Busca pagos de locales por fecha de pago y otros filtros
-- --------------------------------------------

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
      || 'FROM public.ta_11_locales a '
      || 'JOIN public.ta_11_pagos_local b ON a.id_local = b.id_local '
      || 'JOIN public.ta_12_passwords c ON b.id_usuario = c.id_usuario '
      || 'WHERE b.fecha_pago = $1 AND b.oficina_pago = $2 AND b.caja_pago = $3 AND b.operacion_pago = $4 '
      || 'ORDER BY ' || p_orden || ' LIMIT $5 OFFSET $6';
  RETURN QUERY EXECUTE sql USING p_fecha_pago, p_oficina_pago, p_caja_pago, p_operacion_pago, p_limit, p_offset;
END; $$ LANGUAGE plpgsql;

-- ============================================

