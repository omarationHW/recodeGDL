-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: sQRptTipos_Aseo
-- Generado: 2025-08-27 15:38:00
-- Total SPs: 1
-- ============================================

-- SP 1/1: sp_ta_16_tipo_aseo_report
-- Tipo: Report
-- Descripción: Devuelve el catálogo de tipos de aseo ordenado por el campo seleccionado (1=ctrol_aseo, 2=tipo_aseo, 3=descripcion).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_ta_16_tipo_aseo_report(opcion integer)
RETURNS TABLE (
    ctrol_aseo varchar,
    tipo_aseo varchar,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion
    FROM ta_16_tipo_aseo
    ORDER BY
        CASE WHEN opcion = 1 THEN ctrol_aseo END ASC,
        CASE WHEN opcion = 2 THEN tipo_aseo END ASC,
        CASE WHEN opcion = 3 THEN descripcion END ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================

