-- Stored Procedure: sp_individual_diversos_pagos
-- Tipo: Report
-- Descripción: Devuelve el detalle de pagos de un convenio diverso
-- Generado para formulario: IndividualDiversos
-- Fecha: 2025-08-27 20:47:46

CREATE OR REPLACE FUNCTION sp_individual_diversos_pagos(p_id_conv_resto integer)
RETURNS TABLE(
  id_conv_pago integer,
  fecha_pago date,
  oficina_pago smallint,
  caja_pago varchar,
  operacion_pago integer,
  pago_parcial smallint,
  importe_pago numeric,
  importe_recargo numeric,
  intereses numeric
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      id_conv_pago,
      fecha_pago,
      oficina_pago,
      caja_pago,
      operacion_pago,
      pago_parcial,
      importe_pago,
      importe_recargo,
      (SELECT COALESCE(SUM(importe),0) FROM ta_12_recibosdet WHERE fecha = p.fecha_pago AND id_rec = p.oficina_pago AND caja = p.caja_pago AND operacion = p.operacion_pago AND cuenta IN (173002,173003,453041,453051,453031,453021,453071,453061,453091,453011,453001,46508,550200000,220102000,220301000,220302000,551100000,220601000,220603000,221301000,221701000,221800000,221901000,220101000)) AS intereses
    FROM ta_17_conv_pagos p
    WHERE id_conv_resto = p_id_conv_resto
    ORDER BY pago_parcial;
END;
$$ LANGUAGE plpgsql;