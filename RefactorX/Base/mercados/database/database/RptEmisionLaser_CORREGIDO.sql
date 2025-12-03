-- ============================================
-- SP CORREGIDO: RptEmisionLaser
-- Esquemas corregidos según postgreok.csv
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_rpt_emision_laser(p_oficina integer, p_axo integer, p_periodo integer, p_mercado integer)
RETURNS TABLE(
  id_local integer, oficina smallint, num_mercado smallint, categoria smallint, seccion varchar, local smallint,
  letra_local varchar, bloque varchar, nombre varchar, descripcion_local varchar, axo smallint, categoria_1 smallint,
  seccion_1 varchar, clave_cuota smallint, importe_cuota numeric, axo_1 smallint, adeudo numeric, recargos numeric,
  subtotal numeric, rentaaxos numeric, meses varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local,
         c.axo, c.categoria, c.seccion, c.clave_cuota, c.importe_cuota, d.axo,
         COALESCE(SUM(d.importe),0) AS adeudo,
         COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM padron_licencias.comun.ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS recargos,
         COALESCE(SUM(d.importe),0) + COALESCE(SUM(ROUND((d.importe)*(SELECT SUM(porcentaje_mes) FROM padron_licencias.comun.ta_12_recargos WHERE (axo=d.axo AND mes>=d.periodo) OR (axo>d.axo))/100,2)),0) AS subtotal,
         0 AS rentaaxos, '' AS meses
  FROM padron_licencias.comun.ta_11_locales a
  JOIN padron_licencias.comun.ta_11_mercados b ON a.oficina = b.oficina AND a.num_mercado = b.num_mercado_nvo
  JOIN mercados.public.ta_11_cuo_locales c ON a.categoria = c.categoria AND a.seccion = c.seccion AND a.clave_cuota = c.clave_cuota AND c.axo = p_axo
  LEFT JOIN padron_licencias.comun.ta_11_adeudo_local d ON a.id_local = d.id_local AND ((d.axo = p_axo AND d.periodo < p_periodo) OR (d.axo < p_axo))
  WHERE a.oficina = p_oficina AND a.num_mercado = p_mercado AND a.vigencia = 'A' AND a.bloqueo < 4
    AND a.id_local NOT IN (SELECT id_local FROM padron_licencias.comun.ta_11_pagos_local WHERE id_local = a.id_local AND axo = p_axo AND periodo = p_periodo)
  GROUP BY a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, a.nombre, a.descripcion_local,
           c.axo, c.categoria, c.seccion, c.clave_cuota, c.importe_cuota, d.axo
  ORDER BY a.oficina, a.num_mercado, a.categoria, a.seccion, a.local, a.letra_local, a.bloque, d.axo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_get_pagos_local(p_id_local integer, p_axo integer, p_periodo integer)
RETURNS TABLE(id_pago_local integer, fecha_pago date, importe_pago numeric, folio varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_pago_local, fecha_pago, importe_pago, folio FROM padron_licencias.comun.ta_11_pagos_local WHERE id_local = p_id_local AND axo = p_axo AND periodo = p_periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_get_mes_adeudo(p_id_local integer, p_axo integer)
RETURNS TABLE(id_adeudo_local integer, axo smallint, periodo smallint, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT id_adeudo_local, axo, periodo, importe FROM padron_licencias.comun.ta_11_adeudo_local WHERE id_local = p_id_local AND axo = p_axo ORDER BY axo, periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.sp_get_requerimientos(p_modulo integer, p_id_local integer)
RETURNS TABLE(folio integer, importe_multa numeric, importe_gastos numeric) AS $$
BEGIN
  RETURN QUERY SELECT folio, importe_multa, importe_gastos FROM padron_licencias.comun.ta_15_apremios WHERE modulo = p_modulo AND control_otr = p_id_local AND vigencia = '1' AND clave_practicado = 'P' ORDER BY folio;
END;
$$ LANGUAGE plpgsql;
