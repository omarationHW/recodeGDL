-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mannto_Empresas
-- Generado: 2025-08-27 14:43:05
-- Total SPs: 6
-- ============================================

-- SP 1/6: sp_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas con su tipo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_list()
RETURNS TABLE(num_empresa INT, ctrol_emp INT, descripcion VARCHAR, representante VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT num_empresa, ctrol_emp, descripcion, representante FROM ta_16_empresas ORDER BY num_empresa, ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_empresas_get
-- Tipo: Catalog
-- Descripción: Obtiene una empresa por num_empresa y ctrol_emp
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_get(p_num_empresa INT, p_ctrol_emp INT)
RETURNS TABLE(num_empresa INT, ctrol_emp INT, descripcion VARCHAR, representante VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT num_empresa, ctrol_emp, descripcion, representante FROM ta_16_empresas WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_empresas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva empresa. Devuelve success y message.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_create(p_ctrol_emp INT, p_descripcion VARCHAR, p_representante VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT, num_empresa INT) AS $$
DECLARE
  v_max INT;
BEGIN
  SELECT COALESCE(MAX(num_empresa),0) INTO v_max FROM ta_16_empresas WHERE ctrol_emp = p_ctrol_emp;
  INSERT INTO ta_16_empresas (num_empresa, ctrol_emp, descripcion, representante)
    VALUES (v_max + 1, p_ctrol_emp, p_descripcion, p_representante);
  RETURN QUERY SELECT TRUE, 'Empresa creada correctamente', v_max + 1;
EXCEPTION WHEN unique_violation THEN
  RETURN QUERY SELECT FALSE, 'Ya existe una empresa con ese número y tipo', NULL;
WHEN OTHERS THEN
  RETURN QUERY SELECT FALSE, 'Error al crear empresa: ' || SQLERRM, NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_empresas_update
-- Tipo: CRUD
-- Descripción: Actualiza una empresa existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_update(p_num_empresa INT, p_ctrol_emp INT, p_descripcion VARCHAR, p_representante VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
  UPDATE ta_16_empresas SET descripcion = p_descripcion, representante = p_representante
    WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Empresa actualizada correctamente';
  ELSE
    RETURN QUERY SELECT FALSE, 'Empresa no encontrada';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/6: sp_empresas_delete
-- Tipo: CRUD
-- Descripción: Elimina una empresa si no tiene contratos asociados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_delete(p_num_empresa INT, p_ctrol_emp INT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
  v_count INT;
BEGIN
  SELECT COUNT(*) INTO v_count FROM ta_16_contratos WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF v_count > 0 THEN
    RETURN QUERY SELECT FALSE, 'No se puede eliminar: existen contratos asociados.';
  END IF;
  DELETE FROM ta_16_empresas WHERE num_empresa = p_num_empresa AND ctrol_emp = p_ctrol_emp;
  IF FOUND THEN
    RETURN QUERY SELECT TRUE, 'Empresa eliminada correctamente';
  ELSE
    RETURN QUERY SELECT FALSE, 'Empresa no encontrada';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_list()
RETURNS TABLE(ctrol_emp INT, tipo_empresa VARCHAR, descripcion VARCHAR) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_emp, tipo_empresa, descripcion FROM ta_16_tipos_emp ORDER BY ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

