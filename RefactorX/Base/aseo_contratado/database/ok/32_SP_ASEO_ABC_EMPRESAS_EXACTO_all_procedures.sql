-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_EMPRESAS (EXACTO del archivo original)
-- Archivo: 32_SP_ASEO_ABC_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: sp_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas con su tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_list() RETURNS SETOF RECORD AS $$
BEGIN
  RETURN QUERY
    SELECT a.num_empresa, b.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante
    FROM public.ta_16_empresas a
    JOIN public.ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    ORDER BY a.descripcion, a.num_empresa, b.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_EMPRESAS (EXACTO del archivo original)
-- Archivo: 32_SP_ASEO_ABC_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: sp_empresas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_create(p_ctrol_emp INTEGER, p_descripcion VARCHAR, p_representante VARCHAR) RETURNS TABLE(num_empresa INTEGER, ctrol_emp INTEGER) AS $$
DECLARE
  v_num_empresa INTEGER;
BEGIN
  SELECT COALESCE(MAX(num_empresa),0)+1 INTO v_num_empresa FROM public.ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  INSERT INTO public.ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_num_empresa, p_ctrol_emp, p_descripcion, p_representante);
  RETURN QUERY SELECT v_num_empresa, p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_EMPRESAS (EXACTO del archivo original)
-- Archivo: 32_SP_ASEO_ABC_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: sp_empresas_delete
-- Tipo: CRUD
-- Descripción: Elimina una empresa si no tiene contratos asociados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_delete(p_num_empresa INTEGER, p_ctrol_emp INTEGER) RETURNS INTEGER AS $$
DECLARE
  v_contratos INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_contratos FROM public.ta_16_contratos WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF v_contratos > 0 THEN
    RETURN 0;
  END IF;
  DELETE FROM public.ta_16_empresas WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  RETURN 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_EMPRESAS (EXACTO del archivo original)
-- Archivo: 32_SP_ASEO_ABC_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: sp_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_list() RETURNS TABLE(ctrol_emp INTEGER, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM public.ta_16_tipos_emp ORDER BY ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

