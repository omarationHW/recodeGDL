-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sQRptEmpresas
-- Generado: 2025-08-27 15:34:07
-- Total SPs: 1
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
    FROM ta_16_empresas a
    JOIN ta_16_tipos_emp b ON b.ctrol_emp = a.ctrol_emp
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

