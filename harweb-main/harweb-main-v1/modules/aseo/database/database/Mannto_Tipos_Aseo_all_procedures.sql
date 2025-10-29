-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mannto_Tipos_Aseo
-- Generado: 2025-08-27 14:50:41
-- Total SPs: 6
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
    FROM ta_16_tipo_aseo
    ORDER BY ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/6: sp_cat_tipos_aseo_get
-- Tipo: Catalog
-- Descripción: Obtiene un tipo de aseo por clave
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_get(p_tipo_aseo varchar)
RETURNS TABLE (
    ctrol_aseo integer,
    tipo_aseo varchar(1),
    descripcion varchar(80),
    cta_aplicacion integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion
    FROM ta_16_tipo_aseo
    WHERE tipo_aseo = p_tipo_aseo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/6: sp_cat_tipos_aseo_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de aseo. Valida unicidad y existencia de cuenta de aplicación.
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
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe el tipo de aseo', NULL;
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM ta_12_cuentas WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe', NULL;
        RETURN;
    END IF;
    SELECT COALESCE(MAX(ctrol_aseo),0)+1 INTO v_new_ctrol FROM ta_16_tipo_aseo;
    INSERT INTO ta_16_tipo_aseo (ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion)
    VALUES (v_new_ctrol, p_tipo_aseo, p_descripcion, p_cta_aplicacion);
    RETURN QUERY SELECT true, 'Tipo de aseo creado correctamente', v_new_ctrol;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/6: sp_cat_tipos_aseo_update
-- Tipo: CRUD
-- Descripción: Actualiza un tipo de aseo existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_update(
    p_tipo_aseo varchar(1),
    p_descripcion varchar(80),
    p_cta_aplicacion integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
    v_cta_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'Tipo de aseo no existe';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM ta_12_cuentas WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe';
        RETURN;
    END IF;
    UPDATE ta_16_tipo_aseo SET descripcion = p_descripcion, cta_aplicacion = p_cta_aplicacion
    WHERE tipo_aseo = p_tipo_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo actualizado correctamente';
END;
$$ LANGUAGE plpgsql;

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
    SELECT ctrol_aseo INTO v_ctrol FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_ctrol IS NULL THEN
        RETURN QUERY SELECT false, 'Tipo de aseo no existe';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_contratos FROM ta_16_contratos WHERE ctrol_aseo = v_ctrol;
    IF v_contratos > 0 THEN
        RETURN QUERY SELECT false, 'Existen contratos con este tipo de aseo. No se puede eliminar.';
        RETURN;
    END IF;
    DELETE FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo eliminado correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/6: sp_cat_cta_aplicacion_exists
-- Tipo: Catalog
-- Descripción: Verifica si existe la cuenta de aplicación.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_cta_aplicacion_exists(p_cta integer)
RETURNS TABLE(exists boolean) AS $$
BEGIN
    RETURN QUERY SELECT EXISTS(SELECT 1 FROM ta_12_cuentas WHERE cta_aplicacion = p_cta);
END;
$$ LANGUAGE plpgsql;

-- ============================================

