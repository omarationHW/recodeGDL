-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Rep_Contratos
-- Generado: 2025-08-27 15:07:54
-- Total SPs: 7
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
  FROM ta_16_empresas a
  JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
  ORDER BY a.num_empresa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: sp16_listar_tipo_aseo
-- Tipo: Catalog
-- Descripción: Devuelve todos los tipos de aseo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_listar_tipo_aseo()
RETURNS TABLE(ctrol_aseo INTEGER, tipo_aseo TEXT, descripcion TEXT, cta_aplicacion INTEGER) AS $$
BEGIN
  RETURN QUERY
  SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion
  FROM ta_16_tipo_aseo
  ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

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
  FROM ta_12_recaudadoras
  WHERE id_rec NOT IN (6,8)
  ORDER BY id_rec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: sp16_buscar_empresas
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre (LIKE).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_buscar_empresas(nombre TEXT)
RETURNS TABLE(num_empresa INTEGER, ctrol_emp INTEGER, descripcion TEXT, representante TEXT, tipo_empresa TEXT, descripcion_1 TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante, b.tipo_empresa, b.descripcion
  FROM ta_16_empresas a
  JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
  WHERE a.descripcion ILIKE '%' || nombre || '%'
  ORDER BY a.num_empresa;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: sp16_buscar_contratos
-- Tipo: Report
-- Descripción: Busca contratos según filtros de empresa, tipo de aseo, vigencia y recaudadora.
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
  FROM ta_16_contratos C
  JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
  JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
  JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
  JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
  WHERE (p_empresa_id IS NULL OR C.num_empresa = p_empresa_id)
    AND (p_tipo_aseo_id IS NULL OR C.ctrol_aseo = p_tipo_aseo_id)
    AND (p_vigencia IS NULL OR p_vigencia = 'T' OR C.status_vigencia = p_vigencia)
    AND (p_recaudadora_id IS NULL OR C.id_rec = p_recaudadora_id)
  ORDER BY C.ctrol_aseo, C.num_contrato;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: sp16_reporte_empresa_contratos
-- Tipo: Report
-- Descripción: Reporte de empresas y sus contratos (cabecera + detalle).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_reporte_empresa_contratos(
  p_empresa_id INTEGER,
  p_tipo_aseo_id INTEGER,
  p_vigencia TEXT,
  p_recaudadora_id INTEGER,
  p_orden TEXT
)
RETURNS TABLE(
  num_empresa INTEGER, ctrol_emp INTEGER, nom_empresa TEXT, representante TEXT, tipo_empresa TEXT,
  tipo_aseo TEXT, des_aseo TEXT, num_contrato INTEGER, domicilio TEXT, cantidad_recolec SMALLINT, des_recolec TEXT, id_rec SMALLINT, sector TEXT, ctrol_zona INTEGER, zona SMALLINT, sub_zona SMALLINT, aso_mes_oblig DATE, fecha_hora_baja TIMESTAMP
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante, b.descripcion,
         d.tipo_aseo, d.descripcion, c.num_contrato, c.domicilio, c.cantidad_recolec, e.descripcion, c.id_rec, c.sector, c.ctrol_zona, f.zona, f.sub_zona, c.aso_mes_oblig, c.fecha_hora_baja
  FROM ta_16_empresas a
  JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
  JOIN ta_16_contratos c ON c.num_empresa = a.num_empresa AND c.ctrol_emp = a.ctrol_emp
  JOIN ta_16_tipo_aseo d ON d.ctrol_aseo = c.ctrol_aseo
  JOIN ta_16_unidades e ON e.ctrol_recolec = c.ctrol_recolec
  JOIN ta_16_zonas f ON f.ctrol_zona = c.ctrol_zona
  WHERE (p_empresa_id IS NULL OR a.num_empresa = p_empresa_id)
    AND (p_tipo_aseo_id IS NULL OR c.ctrol_aseo = p_tipo_aseo_id)
    AND (p_vigencia IS NULL OR p_vigencia = 'T' OR c.status_vigencia = p_vigencia)
    AND (p_recaudadora_id IS NULL OR c.id_rec = p_recaudadora_id)
  ORDER BY CASE WHEN p_orden = 'ctrol_emp,num_empresa' THEN a.ctrol_emp END, CASE WHEN p_orden = 'num_empresa,ctrol_emp' THEN a.num_empresa END, c.num_contrato;
END;
$$ LANGUAGE plpgsql;

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
  FROM ta_16_contratos C
  JOIN ta_16_tipo_aseo D ON D.ctrol_aseo = C.ctrol_aseo
  JOIN ta_16_unidades E ON E.ctrol_recolec = C.ctrol_recolec
  JOIN ta_16_zonas F ON F.ctrol_zona = C.ctrol_zona
  JOIN ta_12_recaudadoras G ON G.id_rec = C.id_rec
  WHERE (p_empresa_id IS NULL OR C.num_empresa = p_empresa_id)
    AND (p_tipo_aseo_id IS NULL OR C.ctrol_aseo = p_tipo_aseo_id)
    AND (p_vigencia IS NULL OR p_vigencia = 'T' OR C.status_vigencia = p_vigencia)
    AND (p_recaudadora_id IS NULL OR C.id_rec = p_recaudadora_id)
  ORDER BY CASE WHEN p_orden = 'ctrol_aseo,num_contrato' THEN C.ctrol_aseo END, CASE WHEN p_orden = 'num_contrato,ctrol_aseo' THEN C.num_contrato END;
END;
$$ LANGUAGE plpgsql;

-- ============================================

