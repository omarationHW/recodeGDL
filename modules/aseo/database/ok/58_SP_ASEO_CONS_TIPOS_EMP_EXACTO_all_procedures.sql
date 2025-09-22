-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_TIPOS_EMP (EXACTO del archivo original)
-- Archivo: 58_SP_ASEO_CONS_TIPOS_EMP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp16_tipos_emp_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de empresa. Devuelve el registro insertado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_tipos_emp_create(p_tipo_empresa VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(ctrol_emp INTEGER, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
DECLARE
  new_id INTEGER;
BEGIN
  INSERT INTO public.ta_16_tipos_emp (tipo_empresa, descripcion)
  VALUES (p_tipo_empresa, p_descripcion)
  RETURNING ctrol_emp INTO new_id;
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM public.ta_16_tipos_emp WHERE ctrol_emp = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_TIPOS_EMP (EXACTO del archivo original)
-- Archivo: 58_SP_ASEO_CONS_TIPOS_EMP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp16_tipos_emp_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de empresa si no tiene empresas asociadas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_tipos_emp_delete(p_ctrol_emp INTEGER)
RETURNS TABLE(status TEXT, message TEXT) AS $$
DECLARE
  cnt INTEGER;
BEGIN
  SELECT COUNT(*) INTO cnt FROM public.ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF cnt > 0 THEN
    RETURN QUERY SELECT 'error', 'No se puede eliminar: existen empresas asociadas.';
    RETURN;
  END IF;
  DELETE FROM public.ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT 'ok', 'Eliminado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

