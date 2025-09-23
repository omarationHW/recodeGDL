-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: SeccionesMntto
-- Generado: 2025-08-27 01:31:35
-- Total SPs: 2
-- ============================================

-- SP 1/2: sp_insert_seccion
-- Tipo: CRUD
-- Descripción: Inserta una nueva sección en ta_11_secciones. Retorna éxito o mensaje de error si ya existe.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_seccion(p_seccion VARCHAR(2), p_descripcion VARCHAR(30))
RETURNS TABLE(success boolean, msg text) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.ta_11_secciones WHERE seccion = p_seccion) THEN
        RETURN QUERY SELECT false, 'La sección ya existe';
        RETURN;
    END IF;
    INSERT INTO public.ta_11_secciones(seccion, descripcion) VALUES (p_seccion, p_descripcion);
    RETURN QUERY SELECT true, 'Sección insertada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/2: sp_update_seccion
-- Tipo: CRUD
-- Descripción: Actualiza la descripción de una sección existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_update_seccion(p_seccion VARCHAR(2), p_descripcion VARCHAR(30))
RETURNS TABLE(success boolean, msg text) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.ta_11_secciones WHERE seccion = p_seccion) THEN
        RETURN QUERY SELECT false, 'La sección no existe';
        RETURN;
    END IF;
    UPDATE public.ta_11_secciones SET descripcion = p_descripcion WHERE seccion = p_seccion;
    RETURN QUERY SELECT true, 'Sección actualizada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

