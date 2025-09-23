-- Stored Procedure: get_estadistica_pagosyadeudos
-- Tipo: Report
-- Descripción: Devuelve la estadística de pagos, capturas y adeudos por mercado para una recaudadora y periodo.
-- Generado para formulario: EstadPagosyAdeudos
-- Fecha: 2025-08-27 00:00:48

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
  FROM ta_11_mercados m
  LEFT JOIN (
    SELECT l.num_mercado_nvo, COUNT(DISTINCT l.id_local) AS localpag, SUM(pl.importe_pago) AS pagospag, COUNT(pl.id_pago_local) AS periodospag
    FROM ta_11_locales l
    JOIN ta_11_pagos_local pl ON pl.id_local = l.id_local
    WHERE l.oficina = p_rec AND l.vigencia = 'A' AND pl.fecha_pago BETWEEN p_fecdsd AND p_fechst
    GROUP BY l.num_mercado_nvo
  ) p ON p.num_mercado_nvo = m.num_mercado_nvo
  LEFT JOIN (
    SELECT l.num_mercado_nvo, COUNT(DISTINCT l.id_local) AS localcap, SUM(pl.importe_pago) AS pagoscap, COUNT(pl.id_pago_local) AS periodoscap
    FROM ta_11_locales l
    JOIN ta_11_pagos_local pl ON pl.id_local = l.id_local
    WHERE l.oficina = p_rec AND l.vigencia = 'A' AND pl.fecha_modificacion::date BETWEEN p_fecdsd AND p_fechst
    GROUP BY l.num_mercado_nvo
  ) c ON c.num_mercado_nvo = m.num_mercado_nvo
  LEFT JOIN (
    SELECT l.num_mercado_nvo, COUNT(DISTINCT l.id_local) AS localade, SUM(al.importe) AS pagosade, COUNT(al.id_adeudo_local) AS periodosade
    FROM ta_11_locales l
    JOIN ta_11_adeudo_local al ON al.id_local = l.id_local
    WHERE l.oficina = p_rec AND l.vigencia = 'A' AND ((al.axo = p_axo AND al.periodo <= p_mes) OR (al.axo < p_axo))
    GROUP BY l.num_mercado_nvo
  ) a ON a.num_mercado_nvo = m.num_mercado_nvo
  WHERE m.oficina = p_rec AND m.tipo_emision <> 'B'
  ORDER BY m.num_mercado_nvo;
END;
$$ LANGUAGE plpgsql;