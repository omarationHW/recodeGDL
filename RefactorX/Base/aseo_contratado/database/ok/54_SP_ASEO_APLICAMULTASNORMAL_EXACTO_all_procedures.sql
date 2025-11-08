-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: APLICAMULTASNORMAL (EXACTO del archivo original)
-- Archivo: 54_SP_ASEO_APLICAMULTASNORMAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_get_aplicareq
-- Tipo: Catalog
-- Descripción: Obtiene la configuración actual de aplicación de requerimientos normales.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_aplicareq()
RETURNS TABLE(descripcion TEXT, aplica CHAR(1), porc INTEGER) AS $$
BEGIN
  RETURN QUERY SELECT descripcion, aplica, porc FROM public.ta_aplicareq LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: APLICAMULTASNORMAL (EXACTO del archivo original)
-- Archivo: 54_SP_ASEO_APLICAMULTASNORMAL_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

