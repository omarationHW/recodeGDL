-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_UND_RECOLEC (EXACTO del archivo original)
-- Archivo: 38_SP_ASEO_ABC_UND_RECOLEC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_UND_RECOLEC (EXACTO del archivo original)
-- Archivo: 38_SP_ASEO_ABC_UND_RECOLEC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_UND_RECOLEC (EXACTO del archivo original)
-- Archivo: 38_SP_ASEO_ABC_UND_RECOLEC_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

