-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_ZONAS (EXACTO del archivo original)
-- Archivo: 60_SP_ASEO_CONS_ZONAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_cons_zonas_list
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de zonas ordenado según el campo especificado.
-- --------------------------------------------

-- PostgreSQL stored procedure for listing zonas
CREATE OR REPLACE FUNCTION sp_cons_zonas_list(p_order text DEFAULT 'ctrol_zona')
RETURNS TABLE (
    ctrol_zona integer,
    zona smallint,
    sub_zona smallint,
    descripcion varchar
) AS $$
DECLARE
    sql text;
BEGIN
    sql := 'SELECT ctrol_zona, zona, sub_zona, descripcion FROM public.ta_16_zonas ORDER BY ' || quote_ident(p_order);
    RETURN QUERY EXECUTE sql;
END;
$$ LANGUAGE plpgsql;

-- ============================================

