-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mannto_Tipos_Emp
-- Generado: 2025-08-27 14:52:22
-- Total SPs: 4
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
  SELECT COUNT(*) INTO existe FROM ta_16_tipos_emp WHERE tipo_empresa = p_tipo_empresa;
  IF existe > 0 THEN
    RETURN QUERY SELECT false, 'Ya existe el tipo de empresa';
    RETURN;
  END IF;
  INSERT INTO ta_16_tipos_emp (ctrol_emp, tipo_empresa, descripcion)
    VALUES (DEFAULT, p_tipo_empresa, p_descripcion);
  RETURN QUERY SELECT true, 'Tipo de empresa creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_tipos_emp_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo de empresa.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_update(p_tipo_empresa VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_tipos_emp WHERE tipo_empresa = p_tipo_empresa;
  IF existe = 0 THEN
    RETURN QUERY SELECT false, 'No existe el tipo de empresa';
    RETURN;
  END IF;
  UPDATE ta_16_tipos_emp SET descripcion = p_descripcion WHERE tipo_empresa = p_tipo_empresa;
  RETURN QUERY SELECT true, 'Tipo de empresa actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

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
  SELECT COUNT(*) INTO existe FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF existe > 0 THEN
    RETURN QUERY SELECT false, 'No se puede eliminar: existen empresas asociadas.';
    RETURN;
  END IF;
  DELETE FROM ta_16_tipos_emp WHERE ctrol_emp = p_ctrol_emp;
  RETURN QUERY SELECT true, 'Tipo de empresa eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_tipos_emp_can_delete
-- Tipo: Catalog
-- Descripción: Verifica si un tipo de empresa puede ser eliminado (no tiene empresas asociadas).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_can_delete(p_ctrol_emp INTEGER)
RETURNS TABLE(can_delete boolean) AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  IF existe > 0 THEN
    RETURN QUERY SELECT false;
  ELSE
    RETURN QUERY SELECT true;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

