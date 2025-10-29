-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_TIPOS_EMP (EXACTO del archivo original)
-- Archivo: 37_SP_ASEO_ABC_TIPOS_EMP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_list()
RETURNS TABLE(ctrol_emp integer, tipo_empresa varchar, descripcion varchar) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM public.ta_16_tipos_emp ORDER BY ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_TIPOS_EMP (EXACTO del archivo original)
-- Archivo: 37_SP_ASEO_ABC_TIPOS_EMP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_tipos_emp_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_create(p_ctrol_emp integer, p_tipo_empresa varchar, p_descripcion varchar)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_exists integer;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM public.ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  IF v_exists > 0 THEN
    RETURN QUERY SELECT false, 'Ya existe un tipo de empresa con ese control';
    RETURN;
  END IF;
  INSERT INTO public.ta_16_tipos_emp (ctrol_emp, tipo_empresa, descripcion)
  VALUES (p_ctrol_emp, p_tipo_empresa, p_descripcion);
  RETURN QUERY SELECT true, 'Tipo de empresa creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_TIPOS_EMP (EXACTO del archivo original)
-- Archivo: 37_SP_ASEO_ABC_TIPOS_EMP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_tipos_emp_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de empresa (solo si no tiene empresas asociadas)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_delete(p_ctrol_emp integer)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  v_empresas integer;
BEGIN
  SELECT COUNT(*) INTO v_empresas FROM public.ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF v_empresas > 0 THEN
    RETURN QUERY SELECT false, 'No se puede eliminar: existen empresas asociadas a este tipo';
    RETURN;
  END IF;
  DELETE FROM public.ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT true, 'Tipo de empresa eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

