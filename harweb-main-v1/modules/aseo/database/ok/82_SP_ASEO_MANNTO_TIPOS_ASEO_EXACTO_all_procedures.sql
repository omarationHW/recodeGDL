-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_TIPOS_ASEO (EXACTO del archivo original)
-- Archivo: 82_SP_ASEO_MANNTO_TIPOS_ASEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 1/6: sp_cat_tipos_aseo_list
-- Tipo: Catalog
-- Descripción: Lista todos los tipos de aseo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_list()
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar(1),
    descripcion varchar(80),
    cta_aplicacion integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion
    FROM public.ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_TIPOS_ASEO (EXACTO del archivo original)
-- Archivo: 82_SP_ASEO_MANNTO_TIPOS_ASEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 3/6: sp_cat_tipos_aseo_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de public. Valida unicidad y existencia de cuenta de aplicación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_create(
    p_tipo_aseo varchar(1),
    p_descripcion varchar(80),
    p_cta_aplicacion integer
) RETURNS TABLE(success boolean, message text, ctrol_aseo integer) AS $$
DECLARE
    v_exists integer;
    v_cta_exists integer;
    v_new_ctrol integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe el tipo de aseo', NULL;
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM public.ta_12_cuentas WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe', NULL;
        RETURN;
    END IF;
    SELECT COALESCE(MAX(ctrol_aseo),0)+1 INTO v_new_ctrol FROM public.ta_16_tipo_aseo;
    INSERT INTO public.ta_16_tipo_aseo (ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion)
    VALUES (v_new_ctrol, p_tipo_aseo, p_descripcion, p_cta_aplicacion);
    RETURN QUERY SELECT true, 'Tipo de aseo creado correctamente', v_new_ctrol;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_TIPOS_ASEO (EXACTO del archivo original)
-- Archivo: 82_SP_ASEO_MANNTO_TIPOS_ASEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

-- SP 5/6: sp_cat_tipos_aseo_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de aseo si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_delete(p_tipo_aseo varchar(1))
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_ctrol integer;
    v_contratos integer;
BEGIN
    SELECT ctrol_aseo INTO v_ctrol FROM public.ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_ctrol IS NULL THEN
        RETURN QUERY SELECT false, 'Tipo de aseo no existe';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_contratos FROM public.ta_16_contratos WHERE ctrol_aseo = v_ctrol;
    IF v_contratos > 0 THEN
        RETURN QUERY SELECT false, 'Existen contratos con este tipo de public. No se puede eliminar.';
        RETURN;
    END IF;
    DELETE FROM public.ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_TIPOS_ASEO (EXACTO del archivo original)
-- Archivo: 82_SP_ASEO_MANNTO_TIPOS_ASEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 6 (EXACTO)
-- ============================================

