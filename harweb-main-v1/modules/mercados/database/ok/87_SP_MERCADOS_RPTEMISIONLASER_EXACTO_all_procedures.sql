-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptEmisionLaser
-- Generado: 2025-08-27 20:48:44
-- Total SPs: 8
-- ============================================

-- SP 1/8: sp_rpt_emision_laser
-- Tipo: Report
-- Descripción: Obtiene el reporte principal de emisión laser para una oficina, año, periodo y mercado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rpt_emision_laser(p_oficina integer, p_axo integer, p_periodo integer, p_mercado integer)
RETURNS TABLE(
  id_local integer,
  oficina smallint,
  num_mercado smallint,
  categoria smallint,
  seccion varchar,
  local smallint,
  letra_local varchar,
  bloque varchar,
  nombre varchar,
  descripcion_local varchar,
  axo smallint,
  categoria_1 smallint,
  seccion_1 varchar,
  clave_cuota smallint,
  importe_cuota numeric,
  axo_1 smallint,
  adeudo numeric,
  recargos numeric,
  subtotal numeric,
  rentaaxos numeric,
  meses varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local,
         c.axo, c.categoria, c.seccion, c.clave_cuota, c.importe_cuota, d.axo,
         COALESCE(SUM(d.importe),0) AS adeudo,
         COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM public.ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS recargos,
         COALESCE(SUM(d.importe),0) + COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM public.ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS subtotal,
         0 AS rentaaxos, -- Se calcula en frontend o con otro SP
         '' AS meses
  FROM public.ta_11_locales a
  JOIN public.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
  JOIN public.ta_11_cuo_locales c ON a.categoria = c.categoria AND a.seccion = c.seccion AND a.clave_cuota = c.clave_cuota AND c.axo = p_axo
  LEFT JOIN public.ta_11_adeudo_local d ON a.id_local = d.id_local AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo))
  WHERE a.oficina = p_oficina AND a.num_mercado = p_mercado AND a.vigencia = 'A' AND a.bloqueo < 4
    AND a.id_local NOT IN (
      SELECT id_local FROM public.ta_11_pagos_local WHERE id_local = a.id_local AND axo = p_axo AND periodo = p_periodo
    )
  GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local,
           c.axo, c.categoria, c.seccion, c.clave_cuota, c.importe_cuota, d.axo
  ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, d.axo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/8: sp_get_locales_emision_laser
-- Tipo: Report
-- Descripción: Obtiene los locales para la emisión laser según filtros.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_locales_emision_laser(p_oficina integer, p_mercado integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
  id_local integer,
  nombre varchar,
  descripcion_local varchar,
  meses varchar,
  rentaaxos numeric,
  recargos numeric,
  subtotal numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_local, a.nombre, a.descripcion_local, '' AS meses, 0 AS rentaaxos, 0 AS recargos, 0 AS subtotal
  FROM public.ta_11_locales a
  WHERE a.oficina = p_oficina AND a.num_mercado = p_mercado AND a.vigencia = 'A' AND a.bloqueo < 4;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/8: sp_get_pagos_local
-- Tipo: Report
-- Descripción: Obtiene los pagos de un local para un año y periodo.
-- --------------------------------------------

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
  FROM public.ta_11_pagos_local
  WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/8: sp_get_mes_adeudo
-- Tipo: Report
-- Descripción: Obtiene los meses de adeudo de un local para un año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_mes_adeudo(p_id_local integer, p_axo integer)
RETURNS TABLE(
  id_adeudo_local integer,
  axo smallint,
  periodo smallint,
  importe numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_adeudo_local, axo, periodo, importe
  FROM public.ta_11_adeudo_local
  WHERE id_local = p_id_local AND axo = p_axo
  ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/8: sp_get_requerimientos
-- Tipo: Report
-- Descripción: Obtiene los requerimientos de un local para un módulo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_requerimientos(p_modulo integer, p_id_local integer)
RETURNS TABLE(
  folio integer,
  importe_multa numeric,
  importe_gastos numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT folio, importe_multa, importe_gastos
  FROM public.ta_15_apremios
  WHERE modulo = p_modulo AND control_otr = p_id_local AND vigencia = '1' AND clave_practicado = 'P'
  ORDER BY folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/8: sp_get_recargos_mes
-- Tipo: Report
-- Descripción: Obtiene los recargos de un año y mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_recargos_mes(p_axo integer, p_mes integer)
RETURNS TABLE(
  porcentaje_mes numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT porcentaje_mes FROM public.ta_12_recargos WHERE axo = p_axo AND mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/8: sp_get_fecha_descuento
-- Tipo: Report
-- Descripción: Obtiene la fecha de descuento para un mes.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_fecha_descuento(p_mes integer)
RETURNS TABLE(
  fecha_descuento date,
  fecha_recargos date
) AS $$
BEGIN
  RETURN QUERY
  SELECT fecha_descuento, fecha_recargos FROM public.ta_11_fecha_desc WHERE mes = p_mes;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/8: sp_get_subtotal_local
-- Tipo: Report
-- Descripción: Obtiene el subtotal de adeudo y recargos de un local.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_subtotal_local(p_id_local integer, p_axo integer, p_periodo integer)
RETURNS TABLE(
  adeudo numeric,
  recargos numeric,
  subtotalcalc numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT COALESCE(SUM(d.importe),0) AS adeudo,
         COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM public.ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS recargos,
         COALESCE(SUM(d.importe),0) + COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM public.ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS subtotalcalc
  FROM public.ta_11_adeudo_local d
  WHERE d.id_local = p_id_local AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo));
END;
$$ LANGUAGE plpgsql;

-- ============================================

