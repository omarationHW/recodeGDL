-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_Tipos_Aseo (EXACTO del archivo original)
-- Archivo: 15_SP_ASEO_ABC_TIPOS_ASEO_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_tipos_aseo_create
-- Tipo: CRUD
-- Descripción: Alta de un nuevo tipo de public. Valida unicidad de tipo_aseo y existencia de cta_aplicacion.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_aseo_create(
    p_tipo_aseo VARCHAR(1),
    p_descripcion VARCHAR(80),
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    v_exists INTEGER;
    v_cta_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe el tipo de aseo';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM public.ta_16_ctas_aplicacion WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe';
        RETURN;
    END IF;
    INSERT INTO public.ta_16_tipo_aseo (tipo_aseo, descripcion, cta_aplicacion, usuario_alta, fecha_alta)
    VALUES (p_tipo_aseo, p_descripcion, p_cta_aplicacion, p_usuario, NOW());
    RETURN QUERY SELECT true, 'Tipo de aseo creado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/3: sp_tipos_aseo_update
-- Tipo: CRUD
-- Descripción: Actualiza un tipo de aseo existente. Valida existencia y cuenta de aplicación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_aseo_update(
    p_ctrol_aseo INTEGER,
    p_tipo_aseo VARCHAR(1),
    p_descripcion VARCHAR(80),
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    v_exists INTEGER;
    v_cta_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de aseo';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM public.ta_16_ctas_aplicacion WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe';
        RETURN;
    END IF;
    UPDATE public.ta_16_tipo_aseo
    SET tipo_aseo = p_tipo_aseo,
        descripcion = p_descripcion,
        cta_aplicacion = p_cta_aplicacion,
        usuario_mod = p_usuario,
        fecha_mod = NOW()
    WHERE ctrol_aseo = p_ctrol_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/3: sp_tipos_aseo_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de aseo si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_tipos_aseo_delete(
    p_ctrol_aseo INTEGER,
    p_usuario INTEGER
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    v_exists INTEGER;
    v_has_contracts INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de aseo';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_has_contracts FROM public.ta_16_contratos WHERE ctrol_aseo = p_ctrol_aseo;
    IF v_has_contracts > 0 THEN
        RETURN QUERY SELECT false, 'Existen contratos con este tipo de public. No se puede borrar.';
        RETURN;
    END IF;
    DELETE FROM public.ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================