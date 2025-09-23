-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: EJERCICIOS_INS (EXACTO del archivo original)
-- Archivo: 74_SP_ASEO_EJERCICIOS_INS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 1 (EXACTO)
-- ============================================

-- SP 1/1: sp_create_ejercicio
-- Tipo: Catalog
-- Descripción: Crea un nuevo ejercicio en la tabla ta_16_ejercicios si no existe.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_create_ejercicio(p_ejercicio INTEGER)
RETURNS TEXT AS $$
DECLARE
    existe INTEGER;
BEGIN
    SELECT 1 INTO existe FROM public.ta_16_ejercicios WHERE ejercicio = p_ejercicio;
    IF existe IS NOT NULL THEN
        RETURN 'YA EXISTE EL EJERCICIO';
    END IF;
    INSERT INTO public.ta_16_ejercicios (ejercicio, fecha_hora_alta) VALUES (p_ejercicio, NOW());
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

-- ============================================

