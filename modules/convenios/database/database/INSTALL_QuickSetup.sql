-- ============================================
-- INSTALACIÓN RÁPIDA DE STORED PROCEDURES
-- Proyecto: Convenios
-- Generado: 2025-08-27 20:53:53
-- ============================================

-- Este script contiene solo las definiciones de SPs sin comentarios
-- para una instalación rápida en producción

CREATE OR REPLACE FUNCTION sp_add_tipo(p_descripcion VARCHAR)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
DECLARE
    new_tipo INTEGER;
BEGIN
    SELECT COALESCE(MAX(tipo), 0) + 1 INTO new_tipo FROM ta_17_tipos;
    INSERT INTO ta_17_tipos (tipo, descripcion) VALUES (new_tipo, p_descripcion);
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = new_tipo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_bloquear_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_observaciones VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        bloqueo = 1,
        observaciones = UPPER(TRIM(p_observaciones)),
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
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

CREATE OR REPLACE FUNCTION sp_dar_baja_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_modulo INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        vigencia = 'B',
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
    -- Aquí se puede agregar lógica adicional para afectar otras tablas según el módulo
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_dar_pagado_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_modulo INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        vigencia = 'P',
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
    -- Aquí se puede agregar lógica adicional para afectar otras tablas según el módulo
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_delete_tipo(p_tipo INTEGER)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
DECLARE
    old_tipo INTEGER;
    old_desc VARCHAR;
BEGIN
    SELECT tipo, descripcion INTO old_tipo, old_desc FROM ta_17_tipos WHERE tipo = p_tipo;
    DELETE FROM ta_17_tipos WHERE tipo = p_tipo;
    RETURN QUERY SELECT old_tipo, old_desc;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_desbloquear_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_observaciones VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        bloqueo = 0,
        observaciones = UPPER(TRIM(p_observaciones)),
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual
    WHERE id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_tipos()
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
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

CREATE OR REPLACE FUNCTION sp_listar_subtipos_convenio_diversos(p_tipo INTEGER) RETURNS TABLE (
    subtipo INTEGER,
    desc_subtipo VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT subtipo, desc_subtipo FROM ta_17_subtipo_conv WHERE tipo = p_tipo ORDER BY subtipo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_listar_tipos_convenio_diversos() RETURNS TABLE (
    tipo INTEGER,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_modificar_datos_generales_convenio_diversos(
    p_id_conv_resto INTEGER,
    p_id_rec INTEGER,
    p_id_zona INTEGER,
    p_nombre VARCHAR,
    p_calle VARCHAR,
    p_num_exterior INTEGER,
    p_num_interior INTEGER,
    p_inciso VARCHAR,
    p_metros NUMERIC,
    p_observaciones VARCHAR,
    p_id_usuario INTEGER,
    p_fecha_actual TIMESTAMP,
    p_telefono VARCHAR,
    p_correo VARCHAR,
    p_oficio VARCHAR,
    p_fechaoficio DATE,
    p_nombrefirma VARCHAR,
    p_tipo INTEGER,
    p_subtipo INTEGER,
    p_manzana VARCHAR,
    p_lote INTEGER,
    p_letra VARCHAR,
    p_letras_ofi VARCHAR,
    p_folio_ofi INTEGER,
    p_alo_oficio INTEGER,
    p_modulo INTEGER
) RETURNS VOID AS $$
BEGIN
    UPDATE ta_17_conv_d_resto SET
        id_rec = p_id_rec,
        id_zona = p_id_zona,
        nombre = p_nombre,
        calle = p_calle,
        num_exterior = p_num_exterior,
        num_interior = p_num_interior,
        inciso = p_inciso,
        metros = p_metros,
        observaciones = UPPER(TRIM(p_observaciones)),
        id_usuario = p_id_usuario,
        fecha_actual = p_fecha_actual,
        telefono = p_telefono,
        correo = p_correo,
        oficio = p_oficio,
        fechaoficio = p_fechaoficio,
        nombrefirma = p_nombrefirma
    WHERE id_conv_resto = p_id_conv_resto;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_update_tipo(p_tipo INTEGER, p_descripcion VARCHAR)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    UPDATE ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    RETURN QUERY SELECT tipo, descripcion FROM ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

