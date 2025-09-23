-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Rep_Recaudadoras
-- Generado: 2025-08-27 15:11:42
-- Total SPs: 1
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
    FROM ta_12_recaudadoras
    ORDER BY
        CASE WHEN p_order = 1 THEN id_rec END ASC,
        CASE WHEN p_order = 2 THEN recaudadora END ASC,
        CASE WHEN p_order = 3 THEN domicilio END ASC,
        CASE WHEN p_order = 4 THEN sector END ASC,
        id_rec ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

