-- Stored Procedure: sp_get_datos_convenio
-- Tipo: CRUD
-- Descripción: Obtiene los datos generales de un convenio por id_conv
-- Generado para formulario: DatosConvenio
-- Fecha: 2025-08-26 23:42:58

CREATE OR REPLACE FUNCTION sp_get_datos_convenio(p_id_conv integer)
RETURNS TABLE (
  id_control integer,
  id_conv_resto integer,
  id_referencia integer,
  modulo smallint,
  id_usuario integer,
  fecha_actual timestamp,
  axo_desde smallint,
  mes_desde smallint,
  axo_hasta smallint,
  mes_hasta smallint,
  impuesto numeric,
  recargos numeric,
  gastos numeric,
  multa numeric,
  total numeric,
  referencia varchar,
  anuncio numeric,
  impreso numeric,
  id_conv_resto_1 integer,
  tipo smallint,
  id_conv_diver integer,
  id_referencia_1 integer,
  id_rec smallint,
  id_zona integer,
  nombre varchar,
  calle varchar,
  num_exterior smallint,
  num_interior smallint,
  inciso varchar,
  fecha_inicio date,
  fecha_venc date,
  cantidad_total numeric,
  cantidad_inicio numeric,
  pago_parcial numeric,
  pago_final numeric,
  total_pagos smallint,
  metros float,
  tipo_pago varchar,
  observaciones varchar,
  vigencia varchar,
  id_usuario_1 integer,
  fecha_actual_1 timestamp,
  id_adeudo integer,
  id_conv_resto_2 integer,
  pago_parcial_1 smallint,
  importe numeric,
  fecha_venc_1 date,
  id_usuario_2 integer,
  fecha_actual_2 timestamp,
  clave_pago varchar,
  cve_parcialidad varchar,
  axo_desde_1 smallint,
  mes_desde_1 smallint,
  axo_hasta_1 smallint,
  mes_hasta_1 smallint,
  id_conv_pago integer,
  id_conv_resto_3 integer,
  fecha_pago date,
  oficina_pago smallint,
  caja_pago varchar,
  operacion_pago integer,
  pago_parcial_2 smallint,
  total_parciales smallint,
  importe_pago numeric,
  importe_recargo numeric,
  cve_venc smallint,
  cve_descuento smallint,
  cve_bonificacion smallint,
  id_usuario_3 integer,
  fecha_actual_3 timestamp,
  descripcion varchar,
  desc_subtipo varchar,
  letras_exp varchar,
  numero_exp integer,
  axo_exp smallint,
  estado varchar,
  tipodesc varchar,
  periodos varchar,
  peradeudos varchar,
  convenio varchar
) AS $$
DECLARE
  v_estado varchar;
  v_tipodesc varchar;
  v_periodos varchar;
  v_peradeudos varchar;
  v_convenio varchar;
BEGIN
  RETURN QUERY
  SELECT *,
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
    JOIN ta_17_tipos f ON f.tipo = e.tipo
    JOIN ta_17_subtipo_conv g ON g.tipo = e.tipo AND g.subtipo = e.subtipo
  WHERE a.modulo = 11 AND a.id_referencia = p_id_conv
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;