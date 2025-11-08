-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_ZONAS (EXACTO del archivo original)
-- Archivo: 98_SP_ASEO_REP_ZONAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_rep_zonas_get
-- Tipo: Catalog
-- Descripción: Obtiene la lista de zonas ordenadas según el parámetro.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_rep_zonas_get(p_order smallint)
RETURNS TABLE (
    ctrol_zona integer,
    zona smallint,
    sub_zona smallint,
    descripcion varchar
) AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT ctrol_zona, zona, sub_zona, descripcion FROM public.ta_16_zonas %s',
        CASE p_order
            WHEN 1 THEN 'ORDER BY ctrol_zona'
            WHEN 2 THEN 'ORDER BY zona, sub_zona'
            WHEN 3 THEN 'ORDER BY sub_zona, zona'
            WHEN 4 THEN 'ORDER BY descripcion, ctrol_zona'
            ELSE 'ORDER BY ctrol_zona'
        END
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: REP_ZONAS (EXACTO del archivo original)
-- Archivo: 98_SP_ASEO_REP_ZONAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

