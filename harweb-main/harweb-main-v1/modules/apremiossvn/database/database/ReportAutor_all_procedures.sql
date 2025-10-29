-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ReportAutor
-- Generado: 2025-08-27 14:26:10
-- Total SPs: 4
-- ============================================

-- SP 1/4: sp_report_autorizados
-- Tipo: Report
-- Descripción: Obtiene el reporte de descuentos autorizados para una recaudadora y rango de fechas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_report_autorizados(p_rec integer, p_fecha1 date, p_fecha2 date)
RETURNS TABLE (
  control integer,
  id_rec smallint,
  cveaut integer,
  porcentaje smallint,
  fecha_alta date,
  id_usuarioa integer,
  fecha_baja date,
  estado smallint,
  id_usuario integer,
  fecha_actual timestamp,
  id_control integer,
  zona smallint,
  modulo smallint,
  control_otr integer,
  folio integer,
  diligencia varchar,
  importe_global numeric,
  importe_multa numeric,
  importe_recargo numeric,
  importe_gastos numeric,
  zona_apremio smallint,
  fecha_emision date,
  clave_practicado varchar,
  fecha_practicado date,
  fecha_entrega1 date,
  fecha_entrega2 date,
  fecha_citatorio date,
  hora timestamp,
  ejecutor smallint,
  clave_secuestro smallint,
  clave_remate varchar,
  fecha_remate date,
  porcentaje_multa smallint,
  observaciones varchar,
  fecha_pago date,
  recaudadora smallint,
  caja varchar,
  operacion integer,
  importe_pago numeric,
  vigencia varchar,
  fecha_actualiz date,
  usuario integer,
  clave_mov varchar,
  hora_practicado timestamp,
  datos varchar,
  usu_alta varchar,
  usu_mod varchar,
  quien varchar,
  estadofis varchar,
  vigautoriza varchar,
  contrib varchar,
  nomquien varchar,
  importe_pago_1 numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.control, a.id_rec, a.cveaut, a.porcentaje, a.fecha_alta, a.id_usuarioa, a.fecha_baja, a.estado, a.id_usuario, a.fecha_actual,
    b.id_control, b.zona, b.modulo, b.control_otr, b.folio, b.diligencia, b.importe_global, b.importe_multa, b.importe_recargo, b.importe_gastos, b.zona_apremio, b.fecha_emision, b.clave_practicado, b.fecha_practicado, b.fecha_entrega1, b.fecha_entrega2, b.fecha_citatorio, b.hora, b.ejecutor, b.clave_secuestro, b.clave_remate, b.fecha_remate, b.porcentaje_multa, b.observaciones, b.fecha_pago, b.recaudadora, b.caja, b.operacion, b.importe_pago, b.vigencia, b.fecha_actualiz, b.usuario, b.clave_mov, b.hora_practicado,
    -- datos
    CASE WHEN b.modulo = 16 THEN 'No. Contrato ' || coalesce((SELECT tipo_aseo FROM ta_16_contratos WHERE control_contrato = b.control_otr LIMIT 1),'') || '-' || coalesce((SELECT num_contrato FROM ta_16_contratos WHERE control_contrato = b.control_otr LIMIT 1),'')
         WHEN b.modulo = 11 THEN 'Mercado No. ' || coalesce((SELECT num_mercado FROM ta_11_locales WHERE id_local = b.control_otr LIMIT 1),'') || ' Categoria ' || coalesce((SELECT categoria FROM ta_11_locales WHERE id_local = b.control_otr LIMIT 1),'') || ' Secc. ' || coalesce((SELECT seccion FROM ta_11_locales WHERE id_local = b.control_otr LIMIT 1),'') || ' Local ' || coalesce((SELECT local FROM ta_11_locales WHERE id_local = b.control_otr LIMIT 1),'') || '-' || coalesce((SELECT letra_local FROM ta_11_locales WHERE id_local = b.control_otr LIMIT 1),'') || '-' || coalesce((SELECT bloque FROM ta_11_locales WHERE id_local = b.control_otr LIMIT 1),'')
         ELSE '' END AS datos,
    (SELECT nombre FROM ta_12_passwords WHERE id_usuario = a.id_usuarioa) AS usu_alta,
    (SELECT nombre FROM ta_12_passwords WHERE id_usuario = a.id_usuario) AS usu_mod,
    (SELECT quien FROM ta_15_quienautor WHERE cveaut = a.cveaut) AS quien,
    (SELECT descrip FROM ta_15_claves WHERE clave = b.vigencia AND tipo_clave = 5) AS estadofis,
    CASE WHEN b.vigencia = '2' THEN 'PAGADO' WHEN b.estado = 1 THEN 'ALTA' ELSE 'CANCELADO' END AS vigautoriza,
    CASE WHEN b.modulo = 16 THEN (SELECT representante FROM ta_16_empresas WHERE num_empresa = (SELECT num_empresa FROM ta_16_contratos WHERE control_contrato = b.control_otr LIMIT 1) LIMIT 1)
         WHEN b.modulo = 11 THEN (SELECT nombre FROM ta_11_locales WHERE id_local = b.control_otr LIMIT 1)
         ELSE '' END AS contrib,
    (SELECT nombre FROM ta_15_quienautor WHERE cveaut = a.cveaut) AS nomquien,
    (SELECT totcertificado FROM ta_12_ingreso WHERE fecing = b.fecha_pago AND recing = b.recaudadora AND cajing = b.caja AND opcaja = b.operacion LIMIT 1) AS importe_pago_1
  FROM ta_15_autorizados a
  JOIN ta_15_apremios b ON a.control = b.id_control
  WHERE b.recaudadora = p_rec
    AND b.fecha_pago BETWEEN p_fecha1 AND p_fecha2
    AND a.cveaut NOT IN (1,2)
  ORDER BY a.cveaut, b.vigencia, a.control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_get_rec_info
-- Tipo: Catalog
-- Descripción: Obtiene información de la recaudadora y zona.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_rec_info(p_reca integer)
RETURNS TABLE (
  id_rec smallint,
  zona varchar,
  nomre varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.id_rec, b.zona, c.nomre
  FROM ta_12_recaudadoras a
  JOIN ta_12_zonas b ON a.id_zona = b.id_zona
  JOIN ta_12_nombrerec c ON a.id_rec = c.recing
  WHERE a.id_rec = p_reca;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_cancel_autorizados
-- Tipo: CRUD
-- Descripción: Cancela los autorizados vigentes para un control y fecha de alta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cancel_autorizados(p_id_control integer, p_fecha_alta date)
RETURNS TABLE (updated integer) AS $$
BEGIN
  UPDATE ta_15_autorizados
  SET fecha_baja = CURRENT_DATE, estado = 2
  WHERE control = p_id_control AND fecha_alta = p_fecha_alta AND estado = 1;
  RETURN QUERY SELECT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_set_100porciento
-- Tipo: CRUD
-- Descripción: Actualiza el porcentaje de multa a 100% para un control.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_set_100porciento(p_id_control integer)
RETURNS TABLE (updated integer) AS $$
BEGIN
  UPDATE ta_15_apremios SET porcentaje_multa = 100 WHERE id_control = p_id_control AND porcentaje_multa < 100;
  RETURN QUERY SELECT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================

