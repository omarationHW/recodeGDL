-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_TIPOS_EMP (EXACTO del archivo original)
-- Archivo: 83_SP_ASEO_MANNTO_TIPOS_EMP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_tipos_emp_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de empresa si no existe el tipo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_create(p_tipo_empresa VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM public.ta_16_tipos_emp WHERE tipo_empresa = p_tipo_empresa;
  IF existe > 0 THEN
    RETURN QUERY SELECT false, 'Ya existe el tipo de empresa';
    RETURN;
  END IF;
  INSERT INTO public.ta_16_tipos_emp (ctrol_emp, tipo_empresa, descripcion)
    VALUES (DEFAULT, p_tipo_empresa, p_descripcion);
  RETURN QUERY SELECT true, 'Tipo de empresa creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_TIPOS_EMP (EXACTO del archivo original)
-- Archivo: 83_SP_ASEO_MANNTO_TIPOS_EMP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_tipos_emp_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de empresa si no tiene empresas asociadas.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_delete(p_ctrol_emp INTEGER)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM public.ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF existe > 0 THEN
    RETURN QUERY SELECT false, 'No se puede eliminar: existen empresas asociadas.';
    RETURN;
  END IF;
  DELETE FROM public.ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT true, 'Tipo de empresa eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_TIPOS_EMP (EXACTO del archivo original)
-- Archivo: 83_SP_ASEO_MANNTO_TIPOS_EMP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

