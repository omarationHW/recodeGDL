-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: EstadPagosyAdeudos
-- Generado: 2025-08-27 00:00:48
-- Total SPs: 4
-- ============================================

-- SP 1/4: get_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve el listado de recaudadoras activas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_recaudadoras()
RETURNS TABLE(id_rec smallint, recaudadora varchar, domicilio varchar, tel varchar, recaudador varchar, sector varchar) AS $$
BEGIN
  RETURN QUERY SELECT id_rec, recaudadora, domicilio, tel, recaudador, sector FROM public.ta_12_recaudadoras ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: get_mercados_by_recaudadora
-- Tipo: Catalog
-- Descripción: Devuelve los mercados activos de una public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_mercados_by_recaudadora(p_rec smallint)
RETURNS TABLE(num_mercado_nvo smallint, descripcion varchar, categoria smallint, cuenta_ingreso int, cuenta_energia int, id_zona smallint, tipo_emision varchar) AS $$
BEGIN
  RETURN QUERY SELECT num_mercado_nvo, descripcion, categoria, cuenta_ingreso, cuenta_energia, id_zona, tipo_emision FROM public.ta_11_mercados WHERE oficina = p_rec AND tipo_emision <> 'B' ORDER BY num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: get_estadistica_pagosyadeudos
-- Tipo: Report
-- Descripción: Devuelve la estadística de pagos, capturas y adeudos por mercado para una recaudadora y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_estadistica_pagosyadeudos(
  p_rec smallint, p_axo smallint, p_mes smallint, p_fecdsd date, p_fechst date
)
RETURNS TABLE(
  num_mercado_nvo smallint,
  descripcion varchar,
  localpag int,
  pagospag numeric,
  periodospag numeric,
  localcap int,
  pagoscap numeric,
  periodoscap numeric,
  localade int,
  pagosade numeric,
  periodosade numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.num_mercado_nvo,
    m.descripcion,
    COALESCE(p.localpag,0) AS localpag,
    COALESCE(p.pagospag,0) AS pagospag,
    COALESCE(p.periodospag,0) AS periodospag,
    COALESCE(c.localcap,0) AS localcap,
    COALESCE(c.pagoscap,0) AS pagoscap,
    COALESCE(c.periodoscap,0) AS periodoscap,
    COALESCE(a.localade,0) AS localade,
    COALESCE(a.pagosade,0) AS pagosade,
    COALESCE(a.periodosade,0) AS periodosade
  FROM public.ta_11_mercados m
  LEFT JOIN (
    SELECT l.num_mercado_nvo, COUNT(DISTINCT l.id_local) AS localpag, SUM(pl.importe_pago) AS pagospag, COUNT(pl.id_pago_local) AS periodospag
    FROM public.ta_11_locales l
    JOIN public.ta_11_pagos_local pl ON pl.id_local = l.id_local
    WHERE l.oficina = p_rec AND l.vigencia = 'A' AND pl.fecha_pago BETWEEN p_fecdsd AND p_fechst
    GROUP BY l.num_mercado_nvo
  ) p ON p.num_mercado_nvo = m.num_mercado_nvo
  LEFT JOIN (
    SELECT l.num_mercado_nvo, COUNT(DISTINCT l.id_local) AS localcap, SUM(pl.importe_pago) AS pagoscap, COUNT(pl.id_pago_local) AS periodoscap
    FROM public.ta_11_locales l
    JOIN public.ta_11_pagos_local pl ON pl.id_local = l.id_local
    WHERE l.oficina = p_rec AND l.vigencia = 'A' AND pl.fecha_modificacion::date BETWEEN p_fecdsd AND p_fechst
    GROUP BY l.num_mercado_nvo
  ) c ON c.num_mercado_nvo = m.num_mercado_nvo
  LEFT JOIN (
    SELECT l.num_mercado_nvo, COUNT(DISTINCT l.id_local) AS localade, SUM(al.importe) AS pagosade, COUNT(al.id_adeudo_local) AS periodosade
    FROM public.ta_11_locales l
    JOIN public.ta_11_adeudo_local al ON al.id_local = l.id_local
    WHERE l.oficina = p_rec AND l.vigencia = 'A' AND ((al.axo = p_axo AND al.periodo <= p_mes) OR (al.axo < p_axo))
    GROUP BY l.num_mercado_nvo
  ) a ON a.num_mercado_nvo = m.num_mercado_nvo
  WHERE m.oficina = p_rec AND m.tipo_emision <> 'B'
  ORDER BY m.num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: get_mercado_detalle
-- Tipo: Report
-- Descripción: Devuelve el detalle de pagos y adeudos de un mercado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_mercado_detalle(p_rec smallint, p_mercado smallint)
RETURNS TABLE(
  id_local int,
  nombre varchar,
  pagado numeric,
  adeudo numeric,
  periodos_pagados int,
  periodos_adeudo int
) AS $$
BEGIN
  RETURN QUERY
  SELECT l.id_local, l.nombre,
    COALESCE((SELECT SUM(importe_pago) FROM public.ta_11_pagos_local WHERE id_local = l.id_local),0) AS pagado,
    COALESCE((SELECT SUM(importe) FROM public.ta_11_adeudo_local WHERE id_local = l.id_local),0) AS adeudo,
    (SELECT COUNT(*) FROM public.ta_11_pagos_local WHERE id_local = l.id_local) AS periodos_pagados,
    (SELECT COUNT(*) FROM public.ta_11_adeudo_local WHERE id_local = l.id_local) AS periodos_adeudo
  FROM public.ta_11_locales l
  WHERE l.oficina = p_rec AND l.num_mercado = p_mercado;
END;
$$ LANGUAGE plpgsql;

-- ============================================

