-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_Und_Recolec (EXACTO del archivo original)
-- Archivo: 17_SP_ASEO_ABC_UND_RECOLEC_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_unidades_recoleccion_list
-- Tipo: Catalog
-- Descripción: Lista todas las unidades de recolección para un ejercicio dado.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_list(p_ejercicio integer)
RETURNS TABLE (
    ctrol_recolec integer,
    ejercicio_recolec smallint,
    cve_recolec varchar(1),
    descripcion varchar(80),
    costo_unidad numeric(12,2),
    costo_exed numeric(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM public.ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY ejercicio_recolec, cve_recolec;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_unidades_recoleccion_create
-- Tipo: CRUD
-- Descripción: Crea una nueva unidad de recolección.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_create(
    p_ejercicio smallint,
    p_cve varchar(1),
    p_descripcion varchar(80),
    p_costo_unidad numeric(12,2),
    p_costo_exed numeric(12,2),
    p_usuario_id integer
) RETURNS TABLE (status text, ctrol_recolec integer) AS $$
DECLARE
    v_ctrol integer;
BEGIN
    -- Validar existencia
    IF EXISTS (SELECT 1 FROM public.ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_cve) THEN
        RETURN QUERY SELECT 'error: clave ya existe', NULL;
        RETURN;
    END IF;
    -- Generar nuevo control
    SELECT COALESCE(MAX(ctrol_recolec),0)+1 INTO v_ctrol FROM public.ta_16_unidades WHERE ejercicio_recolec = p_ejercicio;
    INSERT INTO public.ta_16_unidades (ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (v_ctrol, p_ejercicio, p_cve, p_descripcion, p_costo_unidad, p_costo_exed);
    RETURN QUERY SELECT 'ok', v_ctrol;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/4: sp_unidades_recoleccion_update
-- Tipo: CRUD
-- Descripción: Actualiza una unidad de recolección existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_update(
    p_ctrol integer,
    p_ejercicio smallint,
    p_cve varchar(1),
    p_descripcion varchar(80),
    p_costo_unidad numeric(12,2),
    p_costo_exed numeric(12,2),
    p_usuario_id integer
) RETURNS TABLE (status text) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.ta_16_unidades WHERE ctrol_recolec = p_ctrol) THEN
        RETURN QUERY SELECT 'error: unidad no existe';
        RETURN;
    END IF;
    UPDATE public.ta_16_unidades
    SET ejercicio_recolec = p_ejercicio,
        cve_recolec = p_cve,
        descripcion = p_descripcion,
        costo_unidad = p_costo_unidad,
        costo_exed = p_costo_exed
    WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT 'ok';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_unidades_recoleccion_delete
-- Tipo: CRUD
-- Descripción: Elimina una unidad de recolección si no está referenciada en contratos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_delete(
    p_ctrol integer
) RETURNS TABLE (status text) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.ta_16_contratos WHERE ctrol_recolec = p_ctrol) THEN
        RETURN QUERY SELECT 'error: existen contratos con esta unidad';
        RETURN;
    END IF;
    DELETE FROM public.ta_16_unidades WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT 'ok';
END;
$$ LANGUAGE plpgsql;

-- ============================================