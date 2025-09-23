-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: COLONIASMNTTO (EXACTO del archivo original)
-- Archivo: 35_SP_CONVENIOS_COLONIASMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_colonias_create
-- Tipo: CRUD
-- Descripción: Inserta una nueva colonia en ta_17_colonias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_colonias_create(
    p_colonia integer,
    p_descripcion varchar,
    p_id_rec integer,
    p_id_zona integer,
    p_col_obra94 integer,
    p_id_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_17_colonias WHERE colonia = p_colonia;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'La colonia ya existe';
        RETURN;
    END IF;
    INSERT INTO public.ta_17_colonias (colonia, descripcion, id_rec, id_zona, col_obra94, id_usuario, fecha_actual)
    VALUES (p_colonia, p_descripcion, p_id_rec, p_id_zona, p_col_obra94, p_id_usuario, CURRENT_TIMESTAMP);
    RETURN QUERY SELECT true, 'Colonia insertada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: COLONIASMNTTO (EXACTO del archivo original)
-- Archivo: 35_SP_CONVENIOS_COLONIASMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_colonias_delete
-- Tipo: CRUD
-- Descripción: Elimina una colonia de ta_17_colonias
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_colonias_delete(
    p_colonia integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_17_colonias WHERE colonia = p_colonia;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'La colonia no existe';
        RETURN;
    END IF;
    DELETE FROM public.ta_17_colonias WHERE colonia = p_colonia;
    RETURN QUERY SELECT true, 'Colonia eliminada correctamente';
END;
$$ LANGUAGE plpgsql;

-- ============================================

