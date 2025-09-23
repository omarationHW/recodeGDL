-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Cons_Cves_operacion
-- Generado: 2025-08-27 14:00:02
-- Total SPs: 3
-- ============================================

-- SP 1/3: sp16_operacion_create
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de operación en ta_16_operacion, validando unicidad de clave y descripción.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_operacion_create(p_cve_operacion VARCHAR, p_descripcion VARCHAR)
RETURNS TABLE(status INT, leyenda TEXT) AS $$
DECLARE
  existe INT;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_operacion WHERE cve_operacion = p_cve_operacion OR descripcion = p_descripcion;
  IF existe > 0 OR p_cve_operacion IS NULL OR p_descripcion IS NULL OR trim(p_cve_operacion) = '' OR trim(p_descripcion) = '' THEN
    RETURN QUERY SELECT 1, 'YA EXISTE O EL CAMPO DE CLAVE ES NULO, INTENTA CON OTRO.';
    RETURN;
  END IF;
  INSERT INTO ta_16_operacion (cve_operacion, descripcion) VALUES (p_cve_operacion, p_descripcion);
  RETURN QUERY SELECT 0, 'NUEVA CLAVE CREADA CORRECTAMENTE.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp16_operacion_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una clave de operación existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_operacion_update(p_ctrol_operacion INT, p_descripcion VARCHAR)
RETURNS TABLE(status INT, leyenda TEXT) AS $$
DECLARE
  existe INT;
BEGIN
  SELECT COUNT(*) INTO existe FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
  IF existe = 0 THEN
    RETURN QUERY SELECT 1, 'NO EXISTE LA CLAVE DE OPERACION.';
    RETURN;
  END IF;
  UPDATE ta_16_operacion SET descripcion = p_descripcion WHERE ctrol_operacion = p_ctrol_operacion;
  RETURN QUERY SELECT 0, 'DESCRIPCION ACTUALIZADA CORRECTAMENTE.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp16_operacion_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de operación si no tiene pagos asociados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp16_operacion_delete(p_ctrol_operacion INT)
RETURNS TABLE(status INT, leyenda TEXT) AS $$
DECLARE
  pagos INT;
BEGIN
  SELECT COUNT(*) INTO pagos FROM ta_16_pagos WHERE ctrol_operacion = p_ctrol_operacion;
  IF pagos > 0 THEN
    RETURN QUERY SELECT 1, 'EXISTEN PAGOS CON ESTA CLAVE DE OPERACION, NO SE PUEDE BORRAR.';
    RETURN;
  END IF;
  DELETE FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
  RETURN QUERY SELECT 0, 'CLAVE DE OPERACION ELIMINADA CORRECTAMENTE.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

