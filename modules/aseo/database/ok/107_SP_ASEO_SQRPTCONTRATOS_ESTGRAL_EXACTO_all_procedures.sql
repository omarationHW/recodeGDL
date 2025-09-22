-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
-- ============================================

-- SP 1/19: sp_get_tipos_aseo
-- Tipo: Catalog
-- Descripción: Obtiene todos los tipos de aseo activos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipos_aseo()
RETURNS TABLE(ctrol_aseo integer, tipo_aseo text, descripcion text, cta_aplicacion integer) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion FROM public.ta_16_tipo_aseo WHERE ctrol_aseo <> 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_ESTGRAL (EXACTO del archivo original)
-- Archivo: 107_SP_ASEO_SQRPTCONTRATOS_ESTGRAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 19 (EXACTO)
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

