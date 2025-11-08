-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_RECAUDADORAS (EXACTO del archivo original)
-- Archivo: 35_SP_ASEO_ABC_RECAUDADORAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_insert_recaudadora
-- Tipo: CRUD
-- Descripción: Inserta una nueva recaudadora si no existe el número.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_insert_recaudadora(p_num_rec SMALLINT, p_descripcion VARCHAR)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una recaudadora con ese número.';
    ELSE
        INSERT INTO public.ta_16_recaudadoras(num_rec, descripcion) VALUES (p_num_rec, p_descripcion);
        RETURN QUERY SELECT TRUE, 'Recaudadora agregada correctamente.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_RECAUDADORAS (EXACTO del archivo original)
-- Archivo: 35_SP_ASEO_ABC_RECAUDADORAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_delete_recaudadora
-- Tipo: CRUD
-- Descripción: Elimina una recaudadora si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_delete_recaudadora(p_num_rec SMALLINT)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM public.ta_16_contratos WHERE id_rec = p_num_rec;
    IF v_count > 0 THEN
        RETURN QUERY SELECT FALSE, 'No se puede eliminar: existen contratos asociados.';
    END IF;
    DELETE FROM public.ta_16_recaudadoras WHERE num_rec = p_num_rec;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Recaudadora eliminada correctamente.';
    ELSE
        RETURN QUERY SELECT FALSE, 'No existe la public.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================

