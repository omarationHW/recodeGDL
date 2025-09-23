-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mannto_Operaciones
-- Generado: 2025-08-27 14:45:58
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp16_operaciones_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de operación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_operaciones_list()
RETURNS TABLE (
  ctrol_operacion integer,
  cve_operacion varchar(1),
  descripcion varchar(80)
) AS $$
BEGIN
  RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion FROM ta_16_operacion ORDER BY ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp16_operaciones_create
-- Tipo: CRUD
-- Descripción: Crea una nueva clave de operación si no existe
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_operaciones_create(p_cve varchar, p_desc varchar)
RETURNS JSON AS $$
DECLARE
  existe integer;
  new_id integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_operacion WHERE cve_operacion = p_cve;
  IF existe > 0 THEN
    RETURN json_build_object('success', false, 'message', 'Ya existe la clave de operación');
  END IF;
  INSERT INTO ta_16_operacion (cve_operacion, descripcion)
    VALUES (p_cve, p_desc)
    RETURNING ctrol_operacion INTO new_id;
  RETURN json_build_object('success', true, 'message', 'Clave creada', 'ctrol_operacion', new_id);
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp16_operaciones_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una clave de operación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_operaciones_update(p_cve varchar, p_desc varchar)
RETURNS JSON AS $$
DECLARE
  existe integer;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_operacion WHERE cve_operacion = p_cve;
  IF existe = 0 THEN
    RETURN json_build_object('success', false, 'message', 'No existe la clave de operación');
  END IF;
  UPDATE ta_16_operacion SET descripcion = p_desc WHERE cve_operacion = p_cve;
  RETURN json_build_object('success', true, 'message', 'Clave actualizada');
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp16_operaciones_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de operación si no tiene pagos asociados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_operaciones_delete(p_ctrol integer)
RETURNS JSON AS $$
DECLARE
  pagos integer;
BEGIN
  SELECT COUNT(*) INTO pagos FROM ta_16_pagos WHERE ctrol_operacion = p_ctrol;
  IF pagos > 0 THEN
    RETURN json_build_object('success', false, 'message', 'No se puede eliminar: existen pagos asociados');
  END IF;
  DELETE FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol;
  RETURN json_build_object('success', true, 'message', 'Clave eliminada');
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp16_operaciones_check_usage
-- Tipo: CRUD
-- Descripción: Verifica si una clave de operación tiene pagos asociados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_operaciones_check_usage(p_ctrol integer)
RETURNS JSON AS $$
DECLARE
  pagos integer;
BEGIN
  SELECT COUNT(*) INTO pagos FROM ta_16_pagos WHERE ctrol_operacion = p_ctrol;
  RETURN json_build_object('success', true, 'in_use', pagos > 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================

