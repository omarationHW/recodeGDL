-- Stored Procedure: sp_get_pagos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de pagos de un contrato/convenio.
-- Generado para formulario: RptCaratulaDatos
-- Fecha: 2025-08-27 15:34:13

CREATE OR REPLACE FUNCTION sp_get_pagos_detalle(p_contrato integer)
RETURNS TABLE (
    id_pago integer,
    id_convenio integer,
    fecha_pago date,
    oficina_pago smallint,
    caja_pago varchar,
    operacion_pago integer,
    pago_parcial smallint,
    total_parciales smallint,
    importe numeric,
    cve_descuento smallint,
    cve_bonificacion smallint,
    id_usuario integer,
    fecha_actual timestamp,
    usuario varchar,
    cvepago varchar,
    recargos numeric,
    recargosnvo numeric,
    RecarCalc numeric,
    parcialidades varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id_pago, a.id_convenio, a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago, a.pago_parcial, a.total_parciales, a.importe, a.cve_descuento, a.cve_bonificacion, a.id_usuario, a.fecha_actual, b.usuario,
    CASE WHEN a.cve_bonificacion = 1 THEN 'DEVOLUCION' ELSE '' END AS cvepago,
    COALESCE((SELECT SUM(importe_cta) FROM ta_12_importes WHERE fecing=a.fecha_pago AND recing=a.oficina_pago AND cajing=a.caja_pago AND opcaja=a.operacion_pago AND cta_aplicacion=46210),0) AS recargos,
    COALESCE((SELECT SUM(importe_cta) FROM cg_12_importes WHERE fecing=a.fecha_pago AND recing=a.oficina_pago AND cajing=a.caja_pago AND opcaja=a.operacion_pago AND cta_aplicacion=570200000),0) AS recargosnvo,
    COALESCE((SELECT SUM(importe_cta) FROM ta_12_importes WHERE fecing=a.fecha_pago AND recing=a.oficina_pago AND cajing=a.caja_pago AND opcaja=a.operacion_pago AND cta_aplicacion=46210),0) +
    COALESCE((SELECT SUM(importe_cta) FROM cg_12_importes WHERE fecing=a.fecha_pago AND recing=a.oficina_pago AND cajing=a.caja_pago AND opcaja=a.operacion_pago AND cta_aplicacion=570200000),0) AS RecarCalc,
    (a.pago_parcial::text || '-' || a.total_parciales::text) AS parcialidades
  FROM ta_17_pagos a
  JOIN ta_12_passwords b ON a.id_usuario = b.id_usuario
  WHERE a.id_convenio = p_contrato
  ORDER BY a.id_convenio, a.fecha_pago, a.oficina_pago, a.caja_pago, a.operacion_pago;
END;
$$ LANGUAGE plpgsql;