-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTEMPRESAS (EXACTO del archivo original)
-- Archivo: 111_SP_ASEO_SQRPTEMPRESAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: rpt_empresas
-- Tipo: Report
-- Descripción: Devuelve el catálogo de empresas con clasificación dinámica según la opción seleccionada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_empresas(opcion integer)
RETURNS TABLE(
    num_empresa integer,
    ctrol_emp integer,
    descripcion text,
    representante text,
    tipo_empresa integer,
    descripcion_1 text
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.num_empresa, a.ctrol_emp, a.descripcion, a.representante,
           b.tipo_empresa, b.descripcion AS descripcion_1
    FROM public.ta_16_empresas a
    JOIN public.ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
    ORDER BY
        CASE WHEN opcion = 1 THEN a.num_empresa END,
        CASE WHEN opcion = 2 THEN b.tipo_empresa END,
        CASE WHEN opcion = 2 THEN a.num_empresa END,
        CASE WHEN opcion = 3 THEN a.descripcion END,
        CASE WHEN opcion = 3 THEN a.num_empresa END,
        CASE WHEN opcion = 4 THEN a.representante END,
        CASE WHEN opcion = 4 THEN a.num_empresa END;
END;
$$ LANGUAGE plpgsql;

-- ============================================

