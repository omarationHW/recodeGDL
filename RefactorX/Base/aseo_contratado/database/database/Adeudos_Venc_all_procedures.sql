-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Adeudos_Venc
-- Generado: 2025-08-27 13:57:03
-- Total SPs: 4
-- ============================================

-- SP 1/4: buscar_contrato_adeudos_vencidos
-- Tipo: CRUD
-- Descripción: Busca contrato y devuelve datos principales para la consulta de adeudos vencidos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION buscar_contrato_adeudos_vencidos(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE (
  num_empresa INTEGER,
  ctrol_emp INTEGER,
  tipo_empresa VARCHAR,
  tipo_emp VARCHAR,
  nom_emp VARCHAR,
  representante VARCHAR,
  control_contrato INTEGER,
  num_contrato INTEGER,
  ctrol_aseo INTEGER,
  tipo_aseo VARCHAR,
  desc_aseo VARCHAR,
  ctrol_recolec INTEGER,
  cve_recolec VARCHAR,
  desc_recolec VARCHAR,
  cantidad_recolec SMALLINT,
  domicilio VARCHAR,
  sector VARCHAR,
  ctrol_zona INTEGER,
  zona SMALLINT,
  sub_zona SMALLINT,
  nom_zona VARCHAR,
  id_rec SMALLINT,
  recaudadora VARCHAR,
  fecha_hora_alta TIMESTAMP,
  status_vigencia VARCHAR,
  aso_mes_oblig DATE,
  cve VARCHAR,
  usuario INTEGER,
  fecha_hora_baja TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT A.num_empresa, A.ctrol_emp, B.tipo_empresa, B.descripcion, A.descripcion, A.representante,
         C.control_contrato, C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion,
         C.ctrol_recolec, E.cve_recolec, E.descripcion, C.cantidad_recolec,
         C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion,
         C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja
  FROM ta_16_empresas A
  JOIN ta_16_tipos_emp B ON B.ctrol_emp = A.ctrol_emp
  JOIN ta_16_contratos C ON C.num_empresa = A.num_empresa AND C.ctrol_emp = A.ctrol_emp
  JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
  JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
  JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
  JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
  WHERE C.num_contrato = p_num_contrato AND C.ctrol_aseo = p_ctrol_aseo
  ORDER BY C.num_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: get_adeudos_vencidos
-- Tipo: Report
-- Descripción: Obtiene los adeudos vencidos de un contrato, filtrando por vigencia y periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_adeudos_vencidos(
  p_control_contrato INTEGER,
  p_vigencia VARCHAR DEFAULT 'V',
  p_aso INTEGER DEFAULT NULL,
  p_mes INTEGER DEFAULT NULL
)
RETURNS TABLE (
  cam VARCHAR,
  control_contrato INTEGER,
  aso_mes_pago DATE,
  ctrol_operacion INTEGER,
  descripcion VARCHAR,
  exedencias SMALLINT,
  importe NUMERIC,
  recargos NUMERIC
) AS $$
DECLARE
  v_periodo TEXT;
  v_periodo_fin TEXT;
BEGIN
  IF p_vigencia = 'V' THEN
    RETURN QUERY
    SELECT 'A' AS cam, a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.descripcion, a.exedencias, a.importe,
      (SELECT COALESCE(SUM(porc_recargo),0) FROM ta_16_recargos r WHERE r.aso_mes_recargo BETWEEN to_char(a.aso_mes_pago, 'YYYY-MM') AND to_char(current_date, 'YYYY-MM')) AS recargos
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V'
    ORDER BY a.aso_mes_pago, a.ctrol_operacion;
  ELSE
    v_periodo := p_aso::text || '-' || lpad(p_mes::text,2,'0');
    RETURN QUERY
    SELECT 'A' AS cam, a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.descripcion, a.exedencias, a.importe,
      (SELECT COALESCE(SUM(porc_recargo),0) FROM ta_16_recargos r WHERE r.aso_mes_recargo BETWEEN to_char(a.aso_mes_pago, 'YYYY-MM') AND v_periodo) AS recargos
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V' AND to_char(a.aso_mes_pago, 'YYYY-MM') <= v_periodo
    ORDER BY a.aso_mes_pago, a.ctrol_operacion;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: get_apremios_adeudos_vencidos
-- Tipo: Report
-- Descripción: Obtiene los apremios (requerimientos, multas, gastos) asociados a un contrato.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_apremios_adeudos_vencidos(p_control_contrato INTEGER)
RETURNS TABLE (
  id_control INTEGER,
  modulo SMALLINT,
  control_otr INTEGER,
  folio INTEGER,
  importe_multa NUMERIC,
  importe_gastos NUMERIC,
  fecha_practicado DATE,
  clave_practicado VARCHAR,
  porcentaje_multa SMALLINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT id_control, modulo, control_otr, folio, importe_multa, importe_gastos, fecha_practicado, clave_practicado, porcentaje_multa
  FROM ta_15_apremios
  WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P'
  ORDER BY id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: reporte_adeudos_vencidos
-- Tipo: Report
-- Descripción: Genera un resumen de adeudos vencidos para un contrato (multas, recargos, gastos, total).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION reporte_adeudos_vencidos(
  p_control_contrato INTEGER,
  p_vigencia VARCHAR DEFAULT 'V',
  p_aso INTEGER DEFAULT NULL,
  p_mes INTEGER DEFAULT NULL
)
RETURNS TABLE (
  requerimientos INTEGER,
  importe_multa NUMERIC,
  importe_gastos NUMERIC,
  importe_recargos NUMERIC,
  total_adeudos NUMERIC
) AS $$
DECLARE
  v_periodo TEXT;
  v_total NUMERIC := 0;
  v_multa NUMERIC := 0;
  v_gastos NUMERIC := 0;
  v_recargos NUMERIC := 0;
  v_req INTEGER := 0;
BEGIN
  -- Multas y gastos
  SELECT COALESCE(SUM(importe_multa),0), COALESCE(SUM(importe_gastos),0), COUNT(*)
    INTO v_multa, v_gastos, v_req
  FROM ta_15_apremios
  WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P';

  -- Recargos y total adeudos
  IF p_vigencia = 'V' THEN
    SELECT COALESCE(SUM((SELECT COALESCE(SUM(porc_recargo),0) FROM ta_16_recargos r WHERE r.aso_mes_recargo BETWEEN to_char(a.aso_mes_pago, 'YYYY-MM') AND to_char(current_date, 'YYYY-MM'))),0),
           COALESCE(SUM(a.importe),0)
      INTO v_recargos, v_total
    FROM ta_16_pagos a
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V';
  ELSE
    v_periodo := p_aso::text || '-' || lpad(p_mes::text,2,'0');
    SELECT COALESCE(SUM((SELECT COALESCE(SUM(porc_recargo),0) FROM ta_16_recargos r WHERE r.aso_mes_recargo BETWEEN to_char(a.aso_mes_pago, 'YYYY-MM') AND v_periodo)),0),
           COALESCE(SUM(a.importe),0)
      INTO v_recargos, v_total
    FROM ta_16_pagos a
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V' AND to_char(a.aso_mes_pago, 'YYYY-MM') <= v_periodo;
  END IF;

  RETURN QUERY SELECT v_req, v_multa, v_gastos, v_recargos, v_total + v_multa + v_gastos + v_recargos;
END;
$$ LANGUAGE plpgsql;

-- ============================================

