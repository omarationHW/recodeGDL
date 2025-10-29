-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Cons_Tipos_Emp
-- Generado: 2025-08-27 14:04:20
-- Total SPs: 3
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
  INSERT INTO ta_16_tipos_emp (tipo_empresa, descripcion)
  VALUES (p_tipo_empresa, p_descripcion)
  RETURNING ctrol_emp INTO new_id;
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp WHERE ctrol_emp = new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp16_tipos_emp_update
-- Tipo: CRUD
-- Descripción: Actualiza un tipo de empresa existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_tipos_emp_update(p_ctrol_emp INTEGER, p_tipo_empresa VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(ctrol_emp INTEGER, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  UPDATE ta_16_tipos_emp
     SET tipo_empresa = p_tipo_empresa,
         descripcion = p_descripcion
   WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

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
  SELECT COUNT(*) INTO cnt FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF cnt > 0 THEN
    RETURN QUERY SELECT 'error', 'No se puede eliminar: existen empresas asociadas.';
    RETURN;
  END IF;
  DELETE FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT 'ok', 'Eliminado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

