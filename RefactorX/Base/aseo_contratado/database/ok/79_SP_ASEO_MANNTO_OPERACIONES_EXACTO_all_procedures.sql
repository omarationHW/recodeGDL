-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_OPERACIONES (EXACTO del archivo original)
-- Archivo: 79_SP_ASEO_MANNTO_OPERACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
  RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion FROM public.ta_16_operacion ORDER BY ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_OPERACIONES (EXACTO del archivo original)
-- Archivo: 79_SP_ASEO_MANNTO_OPERACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
  SELECT COUNT(*) INTO existe FROM public.ta_16_operacion WHERE cve_operacion = p_cve;
  IF existe = 0 THEN
    RETURN json_build_object('success', false, 'message', 'No existe la clave de operación');
  END IF;
  UPDATE public.ta_16_operacion SET descripcion = p_desc WHERE cve_operacion = p_cve;
  RETURN json_build_object('success', true, 'message', 'Clave actualizada');
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_OPERACIONES (EXACTO del archivo original)
-- Archivo: 79_SP_ASEO_MANNTO_OPERACIONES_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
  SELECT COUNT(*) INTO pagos FROM public.ta_16_pagos WHERE ctrol_operacion = p_ctrol;
  RETURN json_build_object('success', true, 'in_use', pagos > 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================

