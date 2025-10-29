-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_CVES_OPERACION (EXACTO del archivo original)
-- Archivo: 55_SP_ASEO_CONS_CVES_OPERACION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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
  SELECT COUNT(*) INTO existe FROM public.ta_16_operacion WHERE cve_operacion = p_cve_operacion OR descripcion = p_descripcion;
  IF existe > 0 OR p_cve_operacion IS NULL OR p_descripcion IS NULL OR trim(p_cve_operacion) = '' OR trim(p_descripcion) = '' THEN
    RETURN QUERY SELECT 1, 'YA EXISTE O EL CAMPO DE CLAVE ES NULO, INTENTA CON OTRO.';
    RETURN;
  END IF;
  INSERT INTO public.ta_16_operacion (cve_operacion, descripcion) VALUES (p_cve_operacion, p_descripcion);
  RETURN QUERY SELECT 0, 'NUEVA CLAVE CREADA CORRECTAMENTE.';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_CVES_OPERACION (EXACTO del archivo original)
-- Archivo: 55_SP_ASEO_CONS_CVES_OPERACION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
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
  SELECT COUNT(*) INTO pagos FROM public.ta_16_pagos WHERE ctrol_operacion = p_ctrol_operacion;
  IF pagos > 0 THEN
    RETURN QUERY SELECT 1, 'EXISTEN PAGOS CON ESTA CLAVE DE OPERACION, NO SE PUEDE BORRAR.';
    RETURN;
  END IF;
  DELETE FROM public.ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
  RETURN QUERY SELECT 0, 'CLAVE DE OPERACION ELIMINADA CORRECTAMENTE.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

