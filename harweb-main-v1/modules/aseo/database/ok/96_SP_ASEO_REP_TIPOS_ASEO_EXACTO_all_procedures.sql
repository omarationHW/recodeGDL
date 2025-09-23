-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_TIPOS_ASEO (EXACTO del archivo original)
-- Archivo: 96_SP_ASEO_REP_TIPOS_ASEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_rep_tipos_aseo_report
-- Tipo: Report
-- Descripción: Devuelve el listado de tipos de aseo ordenado según parámetro: 1-Control, 2-Tipo, 3-Descripción.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_tipos_aseo_report(p_order integer)
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion
    FROM public.ta_16_tipo_aseo
    ORDER BY
        CASE WHEN p_order = 1 THEN ctrol_aseo END ASC,
        CASE WHEN p_order = 2 THEN tipo_aseo END ASC,
        CASE WHEN p_order = 3 THEN descripcion END ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

