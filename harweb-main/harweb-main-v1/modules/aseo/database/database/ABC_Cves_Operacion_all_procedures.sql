-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Cves_Operacion
-- Generado: 2025-08-27 13:21:19
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_cves_operacion_list
-- Tipo: Catalog
-- Descripción: Lista todas las claves de operación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_list()
RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion
    FROM ta_16_operacion
    ORDER BY ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_cves_operacion_get
-- Tipo: Catalog
-- Descripción: Obtiene una clave de operación por ID
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_get(p_ctrol_operacion integer)
RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
BEGIN
    RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion
    FROM ta_16_operacion
    WHERE ctrol_operacion = p_ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_cves_operacion_insert
-- Tipo: CRUD
-- Descripción: Inserta una nueva clave de operación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_insert(
    p_cve_operacion varchar(1),
    p_descripcion varchar(80)
) RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
DECLARE
    new_id integer;
BEGIN
    -- Validar unicidad de clave
    IF EXISTS (SELECT 1 FROM ta_16_operacion WHERE cve_operacion = p_cve_operacion) THEN
        RAISE EXCEPTION 'Ya existe una clave con ese valor';
    END IF;
    INSERT INTO ta_16_operacion (cve_operacion, descripcion)
    VALUES (p_cve_operacion, p_descripcion)
    RETURNING ctrol_operacion, cve_operacion, descripcion INTO new_id, p_cve_operacion, p_descripcion;
    RETURN QUERY SELECT new_id, p_cve_operacion, p_descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_cves_operacion_update
-- Tipo: CRUD
-- Descripción: Actualiza una clave de operación existente
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_update(
    p_ctrol_operacion integer,
    p_cve_operacion varchar(1),
    p_descripcion varchar(80)
) RETURNS TABLE (
    ctrol_operacion integer,
    cve_operacion varchar(1),
    descripcion varchar(80)
) AS $$
BEGIN
    UPDATE ta_16_operacion
    SET cve_operacion = p_cve_operacion,
        descripcion = p_descripcion
    WHERE ctrol_operacion = p_ctrol_operacion;
    RETURN QUERY SELECT ctrol_operacion, cve_operacion, descripcion
    FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_cves_operacion_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de operación (solo si no tiene pagos asociados)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_delete(p_ctrol_operacion integer)
RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_pagos WHERE ctrol_operacion = p_ctrol_operacion) THEN
        RAISE EXCEPTION 'No se puede eliminar: existen pagos asociados a esta clave.';
    END IF;
    DELETE FROM ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

