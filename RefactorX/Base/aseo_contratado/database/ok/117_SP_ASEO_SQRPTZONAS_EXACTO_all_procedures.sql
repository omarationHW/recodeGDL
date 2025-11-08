-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTZONAS (EXACTO del archivo original)
-- Archivo: 117_SP_ASEO_SQRPTZONAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: rpt_ta_16_zonas_report
-- Tipo: Report
-- Descripción: Devuelve el catálogo de zonas ordenado según la opción de clasificación: 1=Control, 2=Zona, 3=Sub-Zona, 4=Descripción.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION rpt_ta_16_zonas_report(opcion integer)
RETURNS TABLE (
    ctrol_zona varchar,
    zona varchar,
    sub_zona varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_zona, zona, sub_zona, descripcion
    FROM public.ta_16_zonas
    ORDER BY
        CASE WHEN opcion = 1 THEN ctrol_zona END ASC,
        CASE WHEN opcion = 2 THEN zona END ASC,
        CASE WHEN opcion = 2 THEN sub_zona END ASC,
        CASE WHEN opcion = 3 THEN sub_zona END ASC,
        CASE WHEN opcion = 3 THEN zona END ASC,
        CASE WHEN opcion = 4 THEN descripcion END ASC,
        CASE WHEN opcion = 4 THEN ctrol_zona END ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

