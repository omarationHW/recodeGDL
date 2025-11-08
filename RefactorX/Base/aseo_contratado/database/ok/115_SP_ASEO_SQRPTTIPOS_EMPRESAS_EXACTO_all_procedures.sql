-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTTIPOS_EMPRESAS (EXACTO del archivo original)
-- Archivo: 115_SP_ASEO_SQRPTTIPOS_EMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_get_tipos_empresas
-- Tipo: Report
-- Descripción: Obtiene el catálogo de tipos de empresas ordenado por el criterio solicitado (1=ctrol_emp, 2=tipo_empresa, 3=descripcion).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tipos_empresas(opcion integer)
RETURNS SETOF ta_16_tipos_emp AS $$
DECLARE
    order_clause text;
    sql_query text;
BEGIN
    IF opcion = 1 THEN
        order_clause := 'ctrol_emp';
    ELSIF opcion = 2 THEN
        order_clause := 'tipo_empresa';
    ELSIF opcion = 3 THEN
        order_clause := 'descripcion';
    ELSE
        order_clause := 'ctrol_emp';
    END IF;
    sql_query := 'SELECT * FROM public.ta_16_tipos_emp ORDER BY ' || order_clause;
    RETURN QUERY EXECUTE sql_query;
END;
$$ LANGUAGE plpgsql;

-- ============================================

