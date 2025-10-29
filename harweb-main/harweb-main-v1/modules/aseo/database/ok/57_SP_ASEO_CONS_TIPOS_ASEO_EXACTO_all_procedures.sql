-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_TIPOS_ASEO (EXACTO del archivo original)
-- Archivo: 57_SP_ASEO_CONS_TIPOS_ASEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_cons_tipos_aseo_list
-- Tipo: Catalog
-- Descripción: Devuelve la lista de tipos de aseo ordenada por el campo solicitado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cons_tipos_aseo_list(p_order text DEFAULT 'ctrol_aseo')
RETURNS TABLE(ctrol_aseo integer, tipo_aseo varchar, descripcion varchar) AS $$
DECLARE
  sql text;
BEGIN
  IF p_order NOT IN ('ctrol_aseo', 'tipo_aseo', 'descripcion') THEN
    p_order := 'ctrol_aseo';
  END IF;
  sql := format('SELECT ctrol_aseo, tipo_aseo, descripcion FROM public.ta_16_tipo_aseo ORDER BY %I', p_order);
  RETURN QUERY EXECUTE sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_TIPOS_ASEO (EXACTO del archivo original)
-- Archivo: 57_SP_ASEO_CONS_TIPOS_ASEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

