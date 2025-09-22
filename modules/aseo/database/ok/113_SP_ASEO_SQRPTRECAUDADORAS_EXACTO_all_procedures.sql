-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTRECAUDADORAS (EXACTO del archivo original)
-- Archivo: 113_SP_ASEO_SQRPTRECAUDADORAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_recaudadoras_report
-- Tipo: Report
-- Descripción: Devuelve el catálogo de recaudadoras ordenado según la opción seleccionada (1: id_rec, 2: recaudadora, 3: domicilio, 4: sector, id_rec).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recaudadoras_report(opcion integer)
RETURNS TABLE (
    id_rec integer,
    recaudadora varchar,
    domicilio varchar,
    sector varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_rec, recaudadora, domicilio, sector
    FROM public.ta_12_recaudadoras
    ORDER BY
        CASE WHEN opcion = 1 THEN id_rec END ASC,
        CASE WHEN opcion = 2 THEN recaudadora END ASC,
        CASE WHEN opcion = 3 THEN domicilio END ASC,
        CASE WHEN opcion = 4 THEN sector END ASC,
        CASE WHEN opcion = 4 THEN id_rec END ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

