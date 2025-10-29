-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_TIPOS_EMP (EXACTO del archivo original)
-- Archivo: 97_SP_ASEO_REP_TIPOS_EMP_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_rep_tipos_empresas
-- Tipo: Report
-- Descripción: Devuelve el catálogo de Tipos de Empresas ordenado según parámetro (1=Control, 2=Tipo, 3=Descripción)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_tipos_empresas(p_order integer)
RETURNS TABLE (
    ctrol_emp integer,
    tipo_empresa varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_emp, tipo_empresa, descripcion
    FROM public.ta_16_tipos_emp
    ORDER BY
        CASE WHEN p_order = 1 THEN ctrol_emp END ASC,
        CASE WHEN p_order = 2 THEN tipo_empresa END ASC,
        CASE WHEN p_order = 3 THEN descripcion END ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

