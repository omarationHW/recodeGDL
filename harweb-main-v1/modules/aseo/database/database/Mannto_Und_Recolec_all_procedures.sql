-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Mannto_Und_Recolec
-- Generado: 2025-08-27 14:54:11
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_cat_unidades_list
-- Tipo: Catalog
-- Descripción: Lista todas las unidades de recolección para un ejercicio dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_list(p_ejercicio INTEGER)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec CHAR(1),
    descripcion VARCHAR(80),
    costo_unidad NUMERIC(12,2),
    costo_exed NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY ctrol_recolec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_cat_unidades_get
-- Tipo: Catalog
-- Descripción: Obtiene una unidad de recolección por su control.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_get(p_ctrol_recolec INTEGER)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec CHAR(1),
    descripcion VARCHAR(80),
    costo_unidad NUMERIC(12,2),
    costo_exed NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM ta_16_unidades
    WHERE ctrol_recolec = p_ctrol_recolec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_cat_unidades_insert
-- Tipo: CRUD
-- Descripción: Inserta una nueva unidad de recolección si no existe la clave para el ejercicio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_insert(
    p_ejercicio SMALLINT,
    p_cve CHAR(1),
    p_descripcion VARCHAR(80),
    p_costo NUMERIC(12,2),
    p_costo_exed NUMERIC(12,2)
) RETURNS TABLE(success BOOLEAN, message TEXT, ctrol_recolec INTEGER) AS $$
DECLARE
    v_exists INTEGER;
    v_new_id INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_cve;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una clave para ese ejercicio', NULL;
        RETURN;
    END IF;
    INSERT INTO ta_16_unidades (ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (p_ejercicio, p_cve, p_descripcion, p_costo, p_costo_exed)
    RETURNING ctrol_recolec INTO v_new_id;
    RETURN QUERY SELECT TRUE, 'Unidad creada correctamente', v_new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_cat_unidades_update
-- Tipo: CRUD
-- Descripción: Actualiza una unidad de recolección por su control.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_update(
    p_ctrol_recolec INTEGER,
    p_descripcion VARCHAR(80),
    p_costo NUMERIC(12,2),
    p_costo_exed NUMERIC(12,2)
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol_recolec;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe la unidad', NULL;
        RETURN;
    END IF;
    UPDATE ta_16_unidades
    SET descripcion = p_descripcion, costo_unidad = p_costo, costo_exed = p_costo_exed
    WHERE ctrol_recolec = p_ctrol_recolec;
    RETURN QUERY SELECT TRUE, 'Unidad actualizada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_cat_unidades_delete
-- Tipo: CRUD
-- Descripción: Elimina una unidad de recolección si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cat_unidades_delete(p_ctrol_recolec INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_contratos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_contratos FROM ta_16_contratos WHERE ctrol_recolec = p_ctrol_recolec;
    IF v_contratos > 0 THEN
        RETURN QUERY SELECT FALSE, 'Existen contratos asociados a esta unidad. No se puede eliminar.';
        RETURN;
    END IF;
    DELETE FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol_recolec;
    RETURN QUERY SELECT TRUE, 'Unidad eliminada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

