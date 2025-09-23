-- Stored Procedure: edo_cuenta_report
-- Tipo: Report
-- Descripción: Devuelve el reporte detallado de estado de cuenta para impresión, incluyendo pagos y recargos.
-- Generado para formulario: EdoCuenta
-- Fecha: 2025-08-27 14:27:45

CREATE OR REPLACE FUNCTION edo_cuenta_report(p_tipo integer, p_subtipo integer)
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
  pago_parcial integer,
  fecha_pago date,
  oficina_pago integer,
  caja_pago text,
  operacion_pago integer,
  importe_pago numeric,
  importe_recargo numeric
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
    p.pago_parcial,
    p.fecha_pago,
    p.oficina_pago,
    p.caja_pago,
    p.operacion_pago,
    p.importe_pago,
    COALESCE(p.importe_recargo,0) AS importe_recargo
  FROM ta_17_con_reg_pred a
  JOIN ta_17_conv_d_resto b ON b.tipo = a.tipo AND b.id_conv_diver = a.id_conv_predio
  JOIN ta_17_adeudos_div c ON c.id_conv_resto = b.id_conv_resto AND c.clave_pago IS NULL
  LEFT JOIN ta_17_conv_pagos p ON p.id_conv_resto = b.id_conv_resto
  WHERE a.tipo = p_tipo AND a.subtipo = p_subtipo
  GROUP BY a.manzana, a.lote, a.letra, b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total, p.pago_parcial, p.fecha_pago, p.oficina_pago, p.caja_pago, p.operacion_pago, p.importe_pago, p.importe_recargo
  ORDER BY a.manzana, a.lote, a.letra, p.pago_parcial;
END;
$$ LANGUAGE plpgsql;