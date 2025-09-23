-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: FRMREP_UND_RECOLEC (EXACTO del archivo original)
-- Archivo: 101_SP_ASEO_FRMREP_UND_RECOLEC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: sp_und_recolec_list
-- Tipo: Catalog
-- Descripción: Lista las unidades de recolección filtradas por ejercicio y ordenadas según parámetro.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_und_recolec_list(p_ejercicio INTEGER, p_order SMALLINT)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC,
    costo_exed NUMERIC
) AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed FROM public.ta_16_unidades WHERE ejercicio_recolec = %L ORDER BY %s',
        p_ejercicio,
        CASE p_order
            WHEN 1 THEN 'ctrol_recolec'
            WHEN 2 THEN 'cve_recolec'
            WHEN 3 THEN 'descripcion'
            WHEN 4 THEN 'costo_unidad'
            ELSE 'ctrol_recolec' END
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: FRMREP_UND_RECOLEC (EXACTO del archivo original)
-- Archivo: 101_SP_ASEO_FRMREP_UND_RECOLEC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: sp_und_recolec_create
-- Tipo: CRUD
-- Descripción: Crea una nueva unidad de recolección.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_und_recolec_create(
    p_ejercicio SMALLINT,
    p_cve VARCHAR,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE (result TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_cve;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'YA EXISTE';
        RETURN;
    END IF;
    INSERT INTO public.ta_16_unidades (ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (p_ejercicio, p_cve, p_descripcion, p_costo_unidad, p_costo_exed);
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: FRMREP_UND_RECOLEC (EXACTO del archivo original)
-- Archivo: 101_SP_ASEO_FRMREP_UND_RECOLEC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_und_recolec_delete
-- Tipo: CRUD
-- Descripción: Elimina una unidad de recolección si no está referenciada en contratos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_und_recolec_delete(p_ctrol INTEGER)
RETURNS TABLE (result TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_16_contratos WHERE ctrol_recolec = p_ctrol;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'NO SE PUEDE BORRAR: EXISTEN CONTRATOS';
        RETURN;
    END IF;
    DELETE FROM public.ta_16_unidades WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

