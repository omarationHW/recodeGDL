-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_VENC (EXACTO del archivo original)
-- Archivo: 53_SP_ASEO_ADEUDOS_VENC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
  FROM public.ta_16_empresas A
  JOIN public.ta_16_tipos_emp B ON B.ctrol_emp = A.ctrol_emp
  JOIN public.ta_16_contratos C ON C.num_empresa = A.num_empresa AND C.ctrol_emp = A.ctrol_emp
  JOIN public.ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
  JOIN public.ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
  JOIN public.ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
  JOIN public.ta_12_recaudadoras G ON G.id_rec = C.id_rec
  WHERE C.num_contrato = p_num_contrato AND C.ctrol_aseo = p_ctrol_aseo
  ORDER BY C.num_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_VENC (EXACTO del archivo original)
-- Archivo: 53_SP_ASEO_ADEUDOS_VENC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
  FROM public.ta_15_apremios
  WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P'
  ORDER BY id_control;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_VENC (EXACTO del archivo original)
-- Archivo: 53_SP_ASEO_ADEUDOS_VENC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

