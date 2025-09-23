-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_CVES_OPERACION (EXACTO del archivo original)
-- Archivo: 31_SP_ASEO_ABC_CVES_OPERACION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
    FROM public.ta_16_operacion
    ORDER BY ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_CVES_OPERACION (EXACTO del archivo original)
-- Archivo: 31_SP_ASEO_ABC_CVES_OPERACION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
    IF EXISTS (SELECT 1 FROM public.ta_16_operacion WHERE cve_operacion = p_cve_operacion) THEN
        RAISE EXCEPTION 'Ya existe una clave con ese valor';
    END IF;
    INSERT INTO public.ta_16_operacion (cve_operacion, descripcion)
    VALUES (p_cve_operacion, p_descripcion)
    RETURNING ctrol_operacion, cve_operacion, descripcion INTO new_id, p_cve_operacion, p_descripcion;
    RETURN QUERY SELECT new_id, p_cve_operacion, p_descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_CVES_OPERACION (EXACTO del archivo original)
-- Archivo: 31_SP_ASEO_ABC_CVES_OPERACION_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: sp_cves_operacion_delete
-- Tipo: CRUD
-- Descripción: Elimina una clave de operación (solo si no tiene pagos asociados)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_cves_operacion_delete(p_ctrol_operacion integer)
RETURNS VOID AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.ta_16_pagos WHERE ctrol_operacion = p_ctrol_operacion) THEN
        RAISE EXCEPTION 'No se puede eliminar: existen pagos asociados a esta clave.';
    END IF;
    DELETE FROM public.ta_16_operacion WHERE ctrol_operacion = p_ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

