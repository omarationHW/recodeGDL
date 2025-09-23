-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_CONTRATOS (EXACTO del archivo original)
-- Archivo: 92_SP_ASEO_REP_CONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: sp16_listar_empresas
-- Tipo: Catalog
-- Descripción: Devuelve todas las empresas con sus datos principales.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_listar_empresas()
RETURNS TABLE(num_empresa INTEGER, ctrol_emp INTEGER, descripcion TEXT, representante TEXT, tipo_empresa TEXT, descripcion_1 TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante, b.tipo_empresa, b.descripcion
  FROM public.ta_16_empresas a
  JOIN public.ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
  ORDER BY a.num_empresa;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_CONTRATOS (EXACTO del archivo original)
-- Archivo: 92_SP_ASEO_REP_CONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: sp16_listar_recaudadoras
-- Tipo: Catalog
-- Descripción: Devuelve todas las recaudadoras activas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_listar_recaudadoras()
RETURNS TABLE(id_rec INTEGER, recaudadora TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT id_rec, recaudadora
  FROM public.ta_12_recaudadoras
  WHERE id_rec NOT IN (6,8)
  ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_CONTRATOS (EXACTO del archivo original)
-- Archivo: 92_SP_ASEO_REP_CONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: sp16_buscar_contratos
-- Tipo: Report
-- Descripción: Busca contratos según filtros de empresa, tipo de aseo, vigencia y public.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_buscar_contratos(
  p_empresa_id INTEGER,
  p_tipo_aseo_id INTEGER,
  p_vigencia TEXT,
  p_recaudadora_id INTEGER
)
RETURNS TABLE(
  num_contrato INTEGER, ctrol_aseo INTEGER, tipo_aseo TEXT, des_aseo TEXT, ctrol_recolec INTEGER, cve_recolec TEXT, des_recolec TEXT,
  cantidad_recolec SMALLINT, domicilio TEXT, sector TEXT, ctrol_zona INTEGER, zona SMALLINT, sub_zona SMALLINT, des_zona TEXT,
  id_rec SMALLINT, recaudadora TEXT, fecha_hora_alta TIMESTAMP, status_vigencia TEXT, aso_mes_oblig DATE, cve TEXT, usuario INTEGER, fecha_hora_baja TIMESTAMP,
  num_empresa INTEGER, ctrol_emp INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion, C.ctrol_recolec, E.cve_recolec, E.descripcion,
         C.cantidad_recolec, C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion,
         C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja,
         C.num_empresa, C.ctrol_emp
  FROM public.ta_16_contratos C
  JOIN public.ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
  JOIN public.ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
  JOIN public.ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
  JOIN public.ta_12_recaudadoras G ON G.id_rec = C.id_rec
  WHERE (p_empresa_id IS NULL OR C.num_empresa = p_empresa_id)
    AND (p_tipo_aseo_id IS NULL OR C.ctrol_aseo = p_tipo_aseo_id)
    AND (p_vigencia IS NULL OR p_vigencia = 'T' OR C.status_vigencia = p_vigencia)
    AND (p_recaudadora_id IS NULL OR C.id_rec = p_recaudadora_id)
  ORDER BY C.ctrol_aseo, C.num_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_CONTRATOS (EXACTO del archivo original)
-- Archivo: 92_SP_ASEO_REP_CONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: sp16_reporte_contratos
-- Tipo: Report
-- Descripción: Reporte de solo contratos, con filtros y orden.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_reporte_contratos(
  p_empresa_id INTEGER,
  p_tipo_aseo_id INTEGER,
  p_vigencia TEXT,
  p_recaudadora_id INTEGER,
  p_orden TEXT
)
RETURNS TABLE(
  num_contrato INTEGER, ctrol_aseo INTEGER, tipo_aseo TEXT, des_aseo TEXT, ctrol_recolec INTEGER, cve_recolec TEXT, des_recolec TEXT,
  cantidad_recolec SMALLINT, domicilio TEXT, sector TEXT, ctrol_zona INTEGER, zona SMALLINT, sub_zona SMALLINT, des_zona TEXT,
  id_rec SMALLINT, recaudadora TEXT, fecha_hora_alta TIMESTAMP, status_vigencia TEXT, aso_mes_oblig DATE, cve TEXT, usuario INTEGER, fecha_hora_baja TIMESTAMP,
  num_empresa INTEGER, ctrol_emp INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT C.num_contrato, C.ctrol_aseo, D.tipo_aseo, D.descripcion, C.ctrol_recolec, E.cve_recolec, E.descripcion,
         C.cantidad_recolec, C.domicilio, C.sector, C.ctrol_zona, F.zona, F.sub_zona, F.descripcion,
         C.id_rec, G.recaudadora, C.fecha_hora_alta, C.status_vigencia, C.aso_mes_oblig, C.cve, C.usuario, C.fecha_hora_baja,
         C.num_empresa, C.ctrol_emp
  FROM public.ta_16_contratos C
  JOIN public.ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
  JOIN public.ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
  JOIN public.ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
  JOIN public.ta_12_recaudadoras G ON G.id_rec = C.id_rec
  WHERE (p_empresa_id IS NULL OR C.num_empresa = p_empresa_id)
    AND (p_tipo_aseo_id IS NULL OR C.ctrol_aseo = p_tipo_aseo_id)
    AND (p_vigencia IS NULL OR p_vigencia = 'T' OR C.status_vigencia = p_vigencia)
    AND (p_recaudadora_id IS NULL OR C.id_rec = p_recaudadora_id)
  ORDER BY CASE WHEN p_orden = 'ctrol_aseo,num_contrato' THEN C.ctrol_aseo END, CASE WHEN p_orden = 'num_contrato,ctrol_aseo' THEN C.num_contrato END;
END;
$$ LANGUAGE plpgsql;

-- ============================================

