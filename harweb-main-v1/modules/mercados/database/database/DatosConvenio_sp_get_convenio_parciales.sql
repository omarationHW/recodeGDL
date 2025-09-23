-- Stored Procedure: sp_get_convenio_parciales
-- Tipo: Report
-- Descripción: Obtiene las parcialidades del convenio (tabla de pagos parciales)
-- Generado para formulario: DatosConvenio
-- Fecha: 2025-08-26 23:42:58

CREATE OR REPLACE FUNCTION sp_get_convenio_parciales(p_id_conv integer)
RETURNS TABLE (
  pago_parcial_1 smallint,
  descparc varchar,
  importe numeric,
  peradeudos varchar,
  fecha_pago date,
  oficina_pago smallint,
  caja_pago varchar,
  operacion_pago integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.pago_parcial as pago_parcial_1,
    CASE WHEN c.cve_parcialidad = 'I' THEN 'INICIAL'
         WHEN c.cve_parcialidad = 'P' THEN 'PARCIAL'
         ELSE 'FINAL' END as descparc,
    c.importe,
    (c.mes_desde_1::text || '/' || c.axo_desde_1::text || ' - ' || c.mes_hasta_1::text || '/' || c.axo_hasta_1::text) as peradeudos,
    d.fecha_pago,
    d.oficina_pago,
    d.caja_pago,
    d.operacion_pago
  FROM ta_17_referencia a
    JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto
    JOIN ta_17_adeudos_div c ON c.id_conv_resto = a.id_conv_resto
    LEFT JOIN ta_17_conv_pagos d ON d.id_conv_resto = c.id_conv_resto AND d.pago_parcial = c.pago_parcial
  WHERE a.modulo = 11 AND a.id_referencia = p_id_conv
  ORDER BY c.pago_parcial;
END;
$$ LANGUAGE plpgsql;