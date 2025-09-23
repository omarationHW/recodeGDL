-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: TIPOSMNTTO (EXACTO del archivo original)
-- Archivo: 93_SP_CONVENIOS_TIPOSMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_tipos_list
-- Tipo: Catalog
-- Descripción: Devuelve todos los registros del catálogo de tipos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_list()
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    RETURN QUERY SELECT tipo, descripcion FROM public.ta_17_tipos ORDER BY tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: TIPOSMNTTO (EXACTO del archivo original)
-- Archivo: 93_SP_CONVENIOS_TIPOSMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_tipos_update
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de un tipo existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_update(p_tipo integer, p_descripcion varchar)
RETURNS TABLE(tipo integer, descripcion varchar) AS $$
BEGIN
    UPDATE public.ta_17_tipos SET descripcion = p_descripcion WHERE tipo = p_tipo;
    RETURN QUERY SELECT tipo, descripcion FROM public.ta_17_tipos WHERE tipo = p_tipo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: TIPOSMNTTO (EXACTO del archivo original)
-- Archivo: 93_SP_CONVENIOS_TIPOSMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

