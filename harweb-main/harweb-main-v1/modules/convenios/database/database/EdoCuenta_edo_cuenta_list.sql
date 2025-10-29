-- Stored Procedure: edo_cuenta_list
-- Tipo: Report
-- Descripción: Obtiene el listado de estados de cuenta por tipo y subtipo, incluyendo totales de pagos y recargos.
-- Generado para formulario: EdoCuenta
-- Fecha: 2025-08-27 14:27:45

CREATE OR REPLACE FUNCTION edo_cuenta_list(p_tipo integer, p_subtipo integer)
RETURNS TABLE(
  manzana text,
  lote integer,
  letra text,
  id_conv_resto integer,
  nombre text,
  calle text,
  num_exterior integer,
  num_interior integer,
  inciso text,
  cantidad_total numeric,
  adeudo numeric,
  total_importe numeric,
  total_recargos numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.manzana,
    a.lote,
    a.letra,
    b.id_conv_resto,
    b.nombre,
    b.calle,
    b.num_exterior,
    b.num_interior,
    b.inciso,
    b.cantidad_total,
    SUM(c.importe) AS adeudo,
    COALESCE((SELECT SUM(importe_pago) FROM ta_17_conv_pagos WHERE id_conv_resto = b.id_conv_resto), 0) AS total_importe,
    COALESCE((SELECT SUM(COALESCE(importe_recargo,0)) FROM ta_17_conv_pagos WHERE id_conv_resto = b.id_conv_resto), 0) AS total_recargos
  FROM ta_17_con_reg_pred a
  JOIN ta_17_conv_d_resto b ON b.tipo = a.tipo AND b.id_conv_diver = a.id_conv_predio
  JOIN ta_17_adeudos_div c ON c.id_conv_resto = b.id_conv_resto AND c.clave_pago IS NULL
  WHERE a.tipo = p_tipo AND a.subtipo = p_subtipo
  GROUP BY a.manzana, a.lote, a.letra, b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total
  ORDER BY a.manzana, a.lote, a.letra;
END;
$$ LANGUAGE plpgsql;