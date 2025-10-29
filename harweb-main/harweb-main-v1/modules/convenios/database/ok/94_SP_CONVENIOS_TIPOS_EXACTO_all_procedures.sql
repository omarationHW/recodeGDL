-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: TIPOS (EXACTO del archivo original)
-- Archivo: 94_SP_CONVENIOS_TIPOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_add_tipo
-- Tipo: CRUD
-- Descripción: Agrega un nuevo tipo de convenio a la tabla ta_17_tipos.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_add_tipo(p_tipo integer, p_descripcion varchar)
RETURNS boolean AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.ta_17_tipos WHERE tipo = p_tipo) THEN
        RETURN FALSE;
    END IF;
    INSERT INTO public.ta_17_tipos (tipo, descripcion) VALUES (p_tipo, p_descripcion);
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: TIPOS (EXACTO del archivo original)
-- Archivo: 94_SP_CONVENIOS_TIPOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_delete_tipo
-- Tipo: CRUD
-- Descripción: Elimina un tipo de convenio por su clave.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_tipo(p_tipo integer)
RETURNS boolean AS $$
BEGIN
    DELETE FROM public.ta_17_tipos WHERE tipo = p_tipo;
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================================

