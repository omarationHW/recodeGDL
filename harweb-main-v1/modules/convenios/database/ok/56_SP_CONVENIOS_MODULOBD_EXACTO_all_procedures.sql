-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MODULOBD (EXACTO del archivo original)
-- Archivo: 56_SP_CONVENIOS_MODULOBD_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_get_tipos
-- Tipo: Catalog
-- Descripción: Obtiene todos los registros del catálogo de tipos
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipos()
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM public.ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MODULOBD (EXACTO del archivo original)
-- Archivo: 56_SP_CONVENIOS_MODULOBD_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_update_tipo
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_tipo(p_tipo INTEGER, p_descripcion VARCHAR)
RETURNS TABLE(tipo INTEGER, descripcion VARCHAR) AS $$
BEGIN
    UPDATE public.ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    RETURN QUERY SELECT tipo, descripcion FROM public.ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: MODULOBD (EXACTO del archivo original)
-- Archivo: 56_SP_CONVENIOS_MODULOBD_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

