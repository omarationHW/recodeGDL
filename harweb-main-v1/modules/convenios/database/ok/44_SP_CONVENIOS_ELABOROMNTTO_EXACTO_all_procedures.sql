-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ELABOROMNTTO (EXACTO del archivo original)
-- Archivo: 44_SP_CONVENIOS_ELABOROMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_elaboro_mntto_create
-- Tipo: CRUD
-- Descripción: Crea un registro en ta_17_elaboroficio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_create(
    p_id_rec integer,
    p_id_usu_titular integer,
    p_iniciales_titular varchar,
    p_id_usu_elaboro integer,
    p_iniciales_elaboro varchar
) RETURNS integer AS $$
DECLARE
    new_id integer;
BEGIN
    INSERT INTO public.ta_17_elaboroficio (
        id_rec, id_usu_titular, iniciales_titular, id_usu_elaboro, iniciales_elaboro
    ) VALUES (
        p_id_rec, p_id_usu_titular, p_iniciales_titular, p_id_usu_elaboro, p_iniciales_elaboro
    ) RETURNING id_control INTO new_id;
    RETURN new_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ELABOROMNTTO (EXACTO del archivo original)
-- Archivo: 44_SP_CONVENIOS_ELABOROMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_elaboro_mntto_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de ta_17_elaboroficio
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_elaboro_mntto_delete(
    p_id_control integer
) RETURNS integer AS $$
BEGIN
    DELETE FROM public.ta_17_elaboroficio WHERE id_control = p_id_control;
    RETURN 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: ELABOROMNTTO (EXACTO del archivo original)
-- Archivo: 44_SP_CONVENIOS_ELABOROMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

