-- Stored Procedure: get_mercado_detalle
-- Tipo: Report
-- Descripción: Devuelve el detalle de pagos y adeudos de un mercado.
-- Generado para formulario: EstadPagosyAdeudos
-- Fecha: 2025-08-27 00:00:48

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
    COALESCE((SELECT SUM(importe_pago) FROM ta_11_pagos_local WHERE id_local = l.id_local),0) AS pagado,
    COALESCE((SELECT SUM(importe) FROM ta_11_adeudo_local WHERE id_local = l.id_local),0) AS adeudo,
    (SELECT COUNT(*) FROM ta_11_pagos_local WHERE id_local = l.id_local) AS periodos_pagados,
    (SELECT COUNT(*) FROM ta_11_adeudo_local WHERE id_local = l.id_local) AS periodos_adeudo
  FROM ta_11_locales l
  WHERE l.oficina = p_rec AND l.num_mercado = p_mercado;
END;
$$ LANGUAGE plpgsql;