-- Stored Procedure: sp_get_edo_cuenta
-- Tipo: Report
-- Descripción: Obtiene el listado de convenios de regularización de predios para un tipo y subtipo.
-- Generado para formulario: RptEdoCuenta
-- Fecha: 2025-08-27 15:37:22

CREATE OR REPLACE FUNCTION sp_get_edo_cuenta(p_tipo INTEGER, p_subtipo INTEGER)
RETURNS TABLE (
  manzana VARCHAR,
  lote INTEGER,
  letra VARCHAR,
  id_conv_resto INTEGER,
  nombre VARCHAR,
  calle VARCHAR,
  num_exterior SMALLINT,
  num_interior SMALLINT,
  inciso VARCHAR,
  cantidad_total NUMERIC,
  pago_parcial SMALLINT,
  fecha_pago DATE,
  oficina_pago SMALLINT,
  caja_pago VARCHAR,
  operacion_pago INTEGER,
  importe_pago NUMERIC,
  importe_recargo NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.manzana, a.lote, a.letra, b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total,
         d.pago_parcial, d.fecha_pago, d.oficina_pago, d.caja_pago, d.operacion_pago, d.importe_pago, d.importe_recargo
    FROM ta_17_con_reg_pred a
    JOIN ta_17_conv_d_resto b ON b.tipo = a.tipo AND b.id_conv_diver = a.id_conv_predio
    JOIN ta_17_adeudos_div c ON c.id_conv_resto = b.id_conv_resto
    LEFT JOIN ta_17_conv_pagos d ON d.id_conv_resto = b.id_conv_resto
   WHERE a.tipo = p_tipo AND a.subtipo = p_subtipo AND c.clave_pago IS NULL
   GROUP BY a.manzana, a.lote, a.letra, b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.cantidad_total,
            d.pago_parcial, d.fecha_pago, d.oficina_pago, d.caja_pago, d.operacion_pago, d.importe_pago, d.importe_recargo
   ORDER BY a.manzana, a.lote, a.letra, d.pago_parcial;
END;
$$ LANGUAGE plpgsql;