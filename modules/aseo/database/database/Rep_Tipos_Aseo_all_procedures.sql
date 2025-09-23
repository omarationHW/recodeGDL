-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Rep_Tipos_Aseo
-- Generado: 2025-08-27 15:12:58
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_rep_tipos_aseo_report
-- Tipo: Report
-- Descripción: Devuelve el listado de tipos de aseo ordenado según parámetro: 1-Control, 2-Tipo, 3-Descripción.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_tipos_aseo_report(p_order integer)
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion
    FROM ta_16_tipo_aseo
    ORDER BY
        CASE WHEN p_order = 1 THEN ctrol_aseo END ASC,
        CASE WHEN p_order = 2 THEN tipo_aseo END ASC,
        CASE WHEN p_order = 3 THEN descripcion END ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

