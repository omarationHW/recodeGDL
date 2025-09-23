-- Stored Procedure: sp_get_convenio_resumen
-- Tipo: Report
-- Descripción: Obtiene resumen de convenio: periodos, estado, tipo, etc.
-- Generado para formulario: DatosConvenio
-- Fecha: 2025-08-26 23:42:58

CREATE OR REPLACE FUNCTION sp_get_convenio_resumen(p_id_conv integer)
RETURNS TABLE (
  estado varchar,
  tipodesc varchar,
  periodos varchar,
  peradeudos varchar,
  convenio varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    CASE WHEN a.vigencia = 'B' THEN 'BAJA'
         WHEN a.vigencia = 'C' THEN 'CANCELADO'
         WHEN a.vigencia = 'P' THEN 'PAGADO'
         ELSE 'VIGENTE' END as estado,
    CASE WHEN a.tipo_pago = 'S' THEN 'SEMANAL'
         WHEN a.tipo_pago = 'Q' THEN 'QUINCENAL'
         ELSE 'MENSUAL' END as tipodesc,
    (a.mes_desde::text || '/' || a.axo_desde::text || ' - ' || a.mes_hasta::text || '/' || a.axo_hasta::text) as periodos,
    (a.mes_desde_1::text || '/' || a.axo_desde_1::text || ' - ' || a.mes_hasta_1::text || '/' || a.axo_hasta_1::text) as peradeudos,
    (e.letras_exp || '/' || e.numero_exp::text || '/' || e.axo_exp::text) as convenio
  FROM ta_17_referencia a
    JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto
    JOIN ta_17_adeudos_div c ON c.id_conv_resto = a.id_conv_resto
    LEFT JOIN ta_17_conv_pagos d ON d.id_conv_resto = c.id_conv_resto AND d.pago_parcial = c.pago_parcial
    JOIN ta_17_conv_diverso e ON e.tipo = b.tipo AND e.id_conv_diver = b.id_conv_diver
  WHERE a.modulo = 11 AND a.id_referencia = p_id_conv
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;