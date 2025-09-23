-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: RptCaratulaDatos
-- Generado: 2025-08-27 15:34:13
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp_get_caratula_datos
-- Tipo: Report
-- Descripción: Obtiene todos los datos principales de la carátula de un contrato/convenio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_caratula_datos(p_contrato integer)
RETURNS TABLE (
    id_convenio integer,
    colonia smallint,
    calle smallint,
    folio integer,
    nombre varchar,
    desc_calle varchar,
    numero varchar,
    tipo_casa varchar,
    mtrs_frente float,
    mtrs_ancho float,
    metros2 float,
    entre_calle_1 varchar,
    entre_calle_2 varchar,
    pago_total numeric,
    pago_inicial numeric,
    pago_quincenal numeric,
    pagos_parciales smallint,
    fecha_firma date,
    fecha_vencimiento date,
    escritura varchar,
    propiedad varchar,
    compro_dom varchar,
    otros varchar,
    observacion varchar,
    fecha_impresion date,
    fecha_rev date,
    fecha_cancelado date,
    vigencia varchar,
    id_usuario integer,
    fecha_actual timestamp,
    descripcion varchar,
    descripcion_1 varchar,
    descripcion_2 varchar,
    usuario varchar,
    axo_obra smallint,
    vigencia_obra varchar,
    estado_obra varchar,
    estado_cont varchar,
    pagos numeric,
    adeudo numeric,
    recargos numeric,
    total numeric,
    plazo smallint,
    clave_plazo varchar,
    desc_plazo varchar,
    recargos_conv numeric,
    saldo_insoluto numeric,
    descuento smallint,
    clave_historia smallint,
    pago_total_1 numeric,
    pago_inicial_1 numeric,
    pago_quincenal_1 numeric,
    pagos_parciales_1 smallint,
    fecha_firma_1 date,
    fecha_vencimiento_1 date,
    otros_1 varchar,
    observacion_1 varchar,
    saldo_insoluto_1 numeric,
    descuento_1 smallint,
    recargos_conv_1 numeric,
    entrecalles varchar,
    contrato varchar,
    impobra_conv numeric,
    impobra_conv_1 numeric,
    recparcial numeric,
    recparcial1 numeric,
    obraparcial numeric,
    obraparcial1 numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id_convenio, a.colonia, a.calle, a.folio, a.nombre, a.desc_calle, a.numero, a.tipo_casa, a.mtrs_frente, a.mtrs_ancho, a.metros2, a.entre_calle_1, a.entre_calle_2,
    a.pago_total, a.pago_inicial, a.pago_quincenal, a.pagos_parciales, a.fecha_firma, a.fecha_vencimiento, a.escritura, a.propiedad, a.compro_dom, a.otros, a.observacion,
    a.fecha_impresion, a.fecha_rev, a.fecha_cancelado, a.vigencia, a.id_usuario, a.fecha_actual, b.descripcion, c.descripcion, d.descripcion, e.usuario, f.axo_obra, f.vigencia_obra,
    CASE WHEN f.vigencia_obra = 'A' THEN 'VIGENTE' ELSE 'CANCELADA' END AS estado_obra,
    CASE WHEN a.vigencia = 'A' THEN 'VIGENTE' ELSE 'CANCELADO' END AS estado_cont,
    0::numeric AS pagos, -- Se calcula en frontend o con otro SP
    0::numeric AS adeudo,
    0::numeric AS recargos,
    0::numeric AS total,
    f.plazo, f.clave_plazo,
    CASE WHEN f.clave_plazo = 'M' THEN 'MESES' WHEN f.clave_plazo = 'Q' THEN 'QUINCENAS' ELSE 'SEMANAS' END AS desc_plazo,
    g.recargos_conv, g.saldo_insoluto, g.descuento, g.clave_historia, g.pago_total AS pago_total_1, g.pago_inicial AS pago_inicial_1, g.pago_quincenal AS pago_quincenal_1,
    g.pagos_parciales AS pagos_parciales_1, g.fecha_firma AS fecha_firma_1, g.fecha_vencimiento AS fecha_vencimiento_1, g.otros AS otros_1, g.observacion AS observacion_1,
    g.saldo_insoluto AS saldo_insoluto_1, g.descuento AS descuento_1, g.recargos_conv AS recargos_conv_1,
    (a.entre_calle_1 || ' Y ' || a.entre_calle_2) AS entrecalles,
    (a.colonia::text || '-' || a.calle::text || '-' || a.folio::text) AS contrato,
    g.impobra_conv, g.impobra_conv AS impobra_conv_1,
    CASE WHEN g.clave_historia=2 THEN g.recargos_conv / NULLIF(g.pagos_parciales,0) ELSE 0 END AS recparcial,
    CASE WHEN g.clave_historia=2 THEN g.recargos_conv_1 / NULLIF(g.pagos_parciales_1,0) ELSE 0 END AS recparcial1,
    CASE WHEN g.clave_historia=2 THEN g.pago_quincenal - (g.recargos_conv / NULLIF(g.pagos_parciales,0)) ELSE 0 END AS obraparcial,
    CASE WHEN g.clave_historia=2 THEN g.pago_quincenal_1 - (g.recargos_conv_1 / NULLIF(g.pagos_parciales_1,0)) ELSE 0 END AS obraparcial1
  FROM ta_17_convenios a
  JOIN ta_17_colonias b ON a.colonia = b.colonia
  JOIN ta_17_servicios c ON a.servicio = c.servicio
  JOIN ta_17_tipos d ON a.tipo = d.tipo
  JOIN ta_12_passwords e ON a.id_usuario = e.id_usuario
  JOIN ta_17_calles f ON a.colonia = f.colonia AND a.calle = f.calle
  LEFT JOIN ta_17_hist_conv g ON g.id_convenio = a.id_convenio AND g.clave_historia = 1
  WHERE a.id_convenio = p_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_get_pagos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de pagos de un contrato/convenio.
-- --------------------------------------------

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

-- ============================================

-- SP 3/3: sp_get_ampliacion_plazo
-- Tipo: Report
-- Descripción: Obtiene la última ampliación de plazo vigente para un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_ampliacion_plazo(p_contrato integer)
RETURNS TABLE (
    id_convenio integer,
    axo_oficio smallint,
    folio_oficio varchar,
    total numeric,
    fecha_inicio date,
    fecha_fin date
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_convenio, axo_oficio, folio_oficio, total, fecha_inicio, fecha_fin
  FROM ta_17_amp_plazo
  WHERE id_convenio = p_contrato AND vigencia = 'A'
  ORDER BY axo_oficio DESC, folio_oficio DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

