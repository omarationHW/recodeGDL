CREATE OR REPLACE FUNCTION sp_individual_diversos_resumen(p_id_conv_resto integer)
RETURNS TABLE(
  total_adeudos numeric,
  total_recargos numeric,
  total_intereses numeric,
  total_pagos numeric,
  total numeric
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      COALESCE(SUM(a.importe),0) AS total_adeudos,
      COALESCE(SUM(a.recargos),0) AS total_recargos,
      COALESCE(SUM(a.interes),0) AS total_intereses,
      (SELECT COALESCE(SUM(p.importe_pago),0) FROM ta_17_conv_pagos p WHERE p.id_conv_resto = p_id_conv_resto) AS total_pagos,
      COALESCE(SUM(a.importe + a.recargos + a.interes),0) AS total
    FROM ta_17_adeudos_div a
    WHERE a.id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_individual_diversos_adeudos(p_id_conv_resto integer)
RETURNS TABLE(
  id_adeudo integer,
  pago_parcial smallint,
  importe numeric,
  fecha_venc date,
  recargos numeric,
  interes numeric,
  total numeric,
  cve_parcialidad varchar,
  axo_desde smallint,
  mes_desde smallint,
  axo_hasta smallint,
  mes_hasta smallint
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      id_adeudo,
      pago_parcial,
      importe,
      fecha_venc,
      recargos,
      interes,
      importe + recargos + interes AS total,
      cve_parcialidad,
      axo_desde,
      mes_desde,
      axo_hasta,
      mes_hasta
    FROM ta_17_adeudos_div
    WHERE id_conv_resto = p_id_conv_resto
    ORDER BY pago_parcial;
END;
$$ LANGUAGE plpgsql;

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

CREATE OR REPLACE FUNCTION sp_individual_diversos_referencias(p_id_conv_resto integer)
RETURNS TABLE(
  id_control integer,
  id_referencia integer,
  modulo smallint,
  referencia varchar,
  axo_desde smallint,
  mes_desde smallint,
  axo_hasta smallint,
  mes_hasta smallint,
  impuesto numeric,
  recargos numeric,
  gastos numeric,
  multa numeric,
  periodos varchar
) AS $$
BEGIN
  RETURN QUERY
    SELECT
      id_control,
      id_referencia,
      modulo,
      referencia,
      axo_desde,
      mes_desde,
      axo_hasta,
      mes_hasta,
      impuesto,
      recargos,
      gastos,
      multa,
      CONCAT(mes_desde, '/', axo_desde, ' - ', mes_hasta, '/', axo_hasta) AS periodos
    FROM ta_17_referencia
    WHERE id_conv_resto = p_id_conv_resto
    ORDER BY id_control;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscar_convenio_diversos(
    p_tipo INTEGER,
    p_subtipo INTEGER,
    p_letras_ofi VARCHAR,
    p_folio_ofi INTEGER,
    p_alo_oficio INTEGER,
    p_manzana VARCHAR DEFAULT NULL
) RETURNS TABLE (
    id_conv_diver INTEGER,
    tipo INTEGER,
    subtipo INTEGER,
    letras_exp VARCHAR,
    numero_exp INTEGER,
    axo_exp INTEGER,
    id_conv_resto INTEGER,
    nombre VARCHAR,
    calle VARCHAR,
    num_exterior INTEGER,
    num_interior INTEGER,
    inciso VARCHAR,
    metros NUMERIC,
    telefono VARCHAR,
    correo VARCHAR,
    oficio VARCHAR,
    fechaoficio DATE,
    nombrefirma VARCHAR,
    observaciones VARCHAR,
    vigencia VARCHAR,
    bloqueo INTEGER,
    modulo INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_conv_diver, a.tipo, a.subtipo, a.letras_exp, a.numero_exp, a.axo_exp,
           b.id_conv_resto, b.nombre, b.calle, b.num_exterior, b.num_interior, b.inciso, b.metros,
           b.telefono, b.correo, b.oficio, b.fechaoficio, b.nombrefirma, b.observaciones, b.vigencia, b.bloqueo, b.modulo
    FROM ta_17_conv_diverso a
    JOIN ta_17_conv_d_resto b ON a.tipo = b.tipo AND a.id_conv_diver = b.id_conv_diver
    WHERE a.tipo = p_tipo AND a.subtipo = p_subtipo
      AND a.letras_exp = COALESCE(p_letras_ofi, a.letras_exp)
      AND a.numero_exp = COALESCE(p_folio_ofi, a.numero_exp)
      AND a.axo_exp = COALESCE(p_alo_oficio, a.axo_exp)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;