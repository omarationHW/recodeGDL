-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_EMPRESAS (EXACTO del archivo original)
-- Archivo: 93_SP_ASEO_REP_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_rep_empresas_report
-- Tipo: Report
-- Descripción: Genera el reporte de empresas ordenado por el criterio solicitado.
-- --------------------------------------------

-- PostgreSQL stored procedure for Empresas Report
CREATE OR REPLACE FUNCTION sp_rep_empresas_report(p_order integer)
RETURNS TABLE (
    num_empresa integer,
    ctrol_emp integer,
    tipo_empresa varchar,
    descripcion varchar,
    representante varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, a.ctrol_emp, b.tipo_empresa, a.descripcion, a.representante
    FROM public.ta_16_empresas a
    JOIN public.ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    ORDER BY
        CASE WHEN p_order = 1 THEN a.num_empresa END ASC,
        CASE WHEN p_order = 2 THEN b.tipo_empresa END ASC,
        CASE WHEN p_order = 3 THEN a.descripcion END ASC,
        CASE WHEN p_order = 4 THEN a.representante END ASC;
END;
$$ LANGUAGE plpgsql;


-- ============================================

