-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_RECAUDADORAS (EXACTO del archivo original)
-- Archivo: 95_SP_ASEO_REP_RECAUDADORAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_rep_recaudadoras_report
-- Tipo: Report
-- Descripción: Devuelve el listado de recaudadoras ordenado según el criterio solicitado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_recaudadoras_report(p_order integer)
RETURNS TABLE(
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
        CASE WHEN p_order = 1 THEN id_rec END ASC,
        CASE WHEN p_order = 2 THEN recaudadora END ASC,
        CASE WHEN p_order = 3 THEN domicilio END ASC,
        CASE WHEN p_order = 4 THEN sector END ASC,
        id_rec ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

