-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sQRptContratos_EstGral
-- Generado: 2025-08-27 15:32:18
-- Total SPs: 19
-- ============================================

-- SP 1/19: sp_get_tipos_aseo
-- Tipo: Catalog
-- Descripción: Obtiene todos los tipos de aseo activos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipos_aseo()
RETURNS TABLE(ctrol_aseo integer, tipo_aseo text, descripcion text, cta_aplicacion integer) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM ta_16_tipo_aseo WHERE ctrol_aseo <> 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/19: sp_get_contratos
-- Tipo: Report
-- Descripción: Obtiene el total de contratos para un tipo de aseo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_contratos(ctrol integer)
RETURNS TABLE(registros float) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float as registros FROM contratos WHERE ctrol_aseo = ctrol;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/19: sp_get_contratos_v
-- Tipo: Report
-- Descripción: Obtiene el total de contratos vigentes para un tipo de aseo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_contratos_v(ctrol integer)
RETURNS TABLE(registros float) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float as registros FROM contratos WHERE ctrol_aseo = ctrol AND estado = 'VIGENTE';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/19: sp_get_contratos_c
-- Tipo: Report
-- Descripción: Obtiene el total de contratos cancelados para un tipo de aseo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_contratos_c(ctrol integer)
RETURNS TABLE(registros float) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float as registros FROM contratos WHERE ctrol_aseo = ctrol AND estado = 'CANCELADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/19: sp_get_cn
-- Tipo: Report
-- Descripción: Obtiene registros e importe de cuota normal para un tipo de aseo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cn(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CN';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/19: sp_get_cn_v
-- Tipo: Report
-- Descripción: Obtiene registros e importe de cuota normal vigentes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cn_v(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CN' AND estado = 'VIGENTE';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/19: sp_get_cn_c
-- Tipo: Report
-- Descripción: Obtiene registros e importe de cuota normal cancelados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cn_c(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CN' AND estado = 'CANCELADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 8/19: sp_get_cn_p
-- Tipo: Report
-- Descripción: Obtiene registros e importe de cuota normal pagados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cn_p(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CN' AND estado = 'PAGADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 9/19: sp_get_cn_s
-- Tipo: Report
-- Descripción: Obtiene registros e importe de cuota normal condonados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cn_s(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CN' AND estado = 'CONDONADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 10/19: sp_get_exe
-- Tipo: Report
-- Descripción: Obtiene registros e importe de excedencias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_exe(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'EXE';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 11/19: sp_get_exe_v
-- Tipo: Report
-- Descripción: Obtiene registros e importe de excedencias vigentes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_exe_v(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'EXE' AND estado = 'VIGENTE';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 12/19: sp_get_exe_c
-- Tipo: Report
-- Descripción: Obtiene registros e importe de excedencias canceladas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_exe_c(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'EXE' AND estado = 'CANCELADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 13/19: sp_get_exe_p
-- Tipo: Report
-- Descripción: Obtiene registros e importe de excedencias pagadas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_exe_p(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'EXE' AND estado = 'PAGADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 14/19: sp_get_exe_s
-- Tipo: Report
-- Descripción: Obtiene registros e importe de excedencias condonadas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_exe_s(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'EXE' AND estado = 'CONDONADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 15/19: sp_get_con
-- Tipo: Report
-- Descripción: Obtiene registros e importe de contenedores
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_con(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CON';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 16/19: sp_get_con_v
-- Tipo: Report
-- Descripción: Obtiene registros e importe de contenedores vigentes
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_con_v(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CON' AND estado = 'VIGENTE';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 17/19: sp_get_con_c
-- Tipo: Report
-- Descripción: Obtiene registros e importe de contenedores cancelados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_con_c(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CON' AND estado = 'CANCELADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 18/19: sp_get_con_p
-- Tipo: Report
-- Descripción: Obtiene registros e importe de contenedores pagados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_con_p(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CON' AND estado = 'PAGADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 19/19: sp_get_con_s
-- Tipo: Report
-- Descripción: Obtiene registros e importe de contenedores condonados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_con_s(ctrol_a integer)
RETURNS TABLE(registros float, importe numeric) AS $$
BEGIN
  RETURN QUERY SELECT COUNT(*)::float, COALESCE(SUM(importe),0) FROM pagos WHERE ctrol_aseo = ctrol_a AND tipo = 'CON' AND estado = 'CONDONADO';
END;
$$ LANGUAGE plpgsql;

-- ============================================

