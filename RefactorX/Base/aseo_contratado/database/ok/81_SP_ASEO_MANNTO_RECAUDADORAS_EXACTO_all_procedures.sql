-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_RECAUDADORAS (EXACTO del archivo original)
-- Archivo: 81_SP_ASEO_MANNTO_RECAUDADORAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_recaudadoras_create
-- Tipo: CRUD
-- Descripción: Crea una nueva recaudadora si no existe el número.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_recaudadoras_create(p_num_rec SMALLINT, p_descripcion VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.ta_16_recaudadoras WHERE num_rec = p_num_rec) THEN
        RAISE EXCEPTION 'YA EXISTE o EL CAMPO DE NUMERO ES NULO, INTENTA CON OTRO.';
    END IF;
    INSERT INTO public.ta_16_recaudadoras (num_rec, descripcion) VALUES (p_num_rec, p_descripcion);
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_RECAUDADORAS (EXACTO del archivo original)
-- Archivo: 81_SP_ASEO_MANNTO_RECAUDADORAS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_recaudadoras_delete
-- Tipo: CRUD
-- Descripción: Elimina una recaudadora si no tiene contratos asociados.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_recaudadoras_delete(p_num_rec SMALLINT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM public.ta_16_contratos WHERE num_rec = p_num_rec) THEN
        RAISE EXCEPTION 'EXISTEN CONTRATOS CON ESTA public. POR LO TANTO NO LO PUEDES BORRAR, INTENTA CON OTRA.';
    END IF;
    DELETE FROM public.ta_16_recaudadoras WHERE num_rec = p_num_rec;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe la recaudadora con ese número.';
    END IF;
END;
$$;

-- ============================================

