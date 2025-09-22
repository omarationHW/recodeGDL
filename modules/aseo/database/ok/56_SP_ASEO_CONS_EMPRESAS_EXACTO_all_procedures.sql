-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_EMPRESAS (EXACTO del archivo original)
-- Archivo: 56_SP_ASEO_CONS_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_empresas_list
-- Tipo: Catalog
-- Descripción: Lista todas las empresas con su tipo y descripción
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_list()
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    descripcion_1 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
           b.tipo_empresa, b.descripcion
    FROM public.ta_16_empresas a
    JOIN public.ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    ORDER BY a.num_empresa, a.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_EMPRESAS (EXACTO del archivo original)
-- Archivo: 56_SP_ASEO_CONS_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_empresas_by_name
-- Tipo: Catalog
-- Descripción: Busca empresas por nombre (LIKE, insensible a mayúsculas)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_empresas_by_name(p_nombre VARCHAR)
RETURNS TABLE (
    num_empresa INTEGER,
    ctrol_emp INTEGER,
    descripcion VARCHAR,
    representante VARCHAR,
    tipo_empresa VARCHAR,
    descripcion_1 VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
           b.tipo_empresa, b.descripcion
    FROM public.ta_16_empresas a
    JOIN public.ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    WHERE unaccent(upper(a.descripcion)) LIKE '%' || unaccent(upper(p_nombre)) || '%'
    ORDER BY a.num_empresa, a.ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: CONS_EMPRESAS (EXACTO del archivo original)
-- Archivo: 56_SP_ASEO_CONS_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_tipos_emp_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de empresa
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_emp_list()
RETURNS TABLE (
    ctrol_emp INTEGER,
    tipo_empresa VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_emp, tipo_empresa, descripcion
    FROM public.ta_16_tipos_emp
    ORDER BY ctrol_emp;
END;
$$ LANGUAGE plpgsql;

-- ============================================

