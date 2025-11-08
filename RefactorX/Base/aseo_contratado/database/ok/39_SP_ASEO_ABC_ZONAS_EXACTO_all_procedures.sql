-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_ZONAS (EXACTO del archivo original)
-- Archivo: 39_SP_ASEO_ABC_ZONAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_zonas_create
-- Tipo: CRUD
-- Descripción: Crea una nueva zona en el catálogo
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonas_create(p_zona integer, p_sub_zona integer, p_descripcion varchar)
RETURNS TABLE(ctrol_zona integer, zona integer, sub_zona integer, descripcion varchar) AS $$
DECLARE
    new_ctrol integer;
BEGIN
    -- Validar existencia
    IF EXISTS (SELECT 1 FROM public.ta_16_zonas WHERE zona = p_zona AND sub_zona = p_sub_zona) THEN
        RAISE EXCEPTION 'Ya existe una zona con esos datos';
    END IF;
    -- Insertar
    INSERT INTO public.ta_16_zonas(zona, sub_zona, descripcion)
    VALUES (p_zona, p_sub_zona, p_descripcion)
    RETURNING ctrol_zona, zona, sub_zona, descripcion INTO new_ctrol, p_zona, p_sub_zona, p_descripcion;
    RETURN QUERY SELECT new_ctrol, p_zona, p_sub_zona, p_descripcion;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_ZONAS (EXACTO del archivo original)
-- Archivo: 39_SP_ASEO_ABC_ZONAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_zonas_delete
-- Tipo: CRUD
-- Descripción: Elimina una zona si no tiene empresas relacionadas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_zonas_delete(p_ctrol_zona integer)
RETURNS TABLE(status text, message text) AS $$
DECLARE
    emp_count integer;
BEGIN
    SELECT COUNT(*) INTO emp_count FROM public.ta_16_empresas WHERE ctrol_zona = p_ctrol_zona;
    IF emp_count > 0 THEN
        RETURN QUERY SELECT 'error', 'No se puede eliminar: existen empresas con esta zona.';
        RETURN;
    END IF;
    DELETE FROM public.ta_16_zonas WHERE ctrol_zona = p_ctrol_zona;
    RETURN QUERY SELECT 'success', 'Zona eliminada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

