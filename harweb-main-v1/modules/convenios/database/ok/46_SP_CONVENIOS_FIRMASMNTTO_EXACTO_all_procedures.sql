-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: FIRMASMNTTO (EXACTO del archivo original)
-- Archivo: 46_SP_CONVENIOS_FIRMASMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_firmas_create
-- Tipo: CRUD
-- Descripción: Inserta un nuevo registro de firmas en ta_17_firmaconv
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_firmas_create(
    p_recaudadora INTEGER,
    p_titular VARCHAR,
    p_cargotitular VARCHAR,
    p_recaudador VARCHAR,
    p_cargorecaudador VARCHAR,
    p_testigo1 VARCHAR,
    p_testigo2 VARCHAR,
    p_letras VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.ta_17_firmaconv (
        recaudadora, titular, cargotitular, recaudador, cargorecaudador, testigo1, testigo2, letras
    ) VALUES (
        p_recaudadora, p_titular, p_cargotitular, p_recaudador, p_cargorecaudador, p_testigo1, p_testigo2, p_letras
    );
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: FIRMASMNTTO (EXACTO del archivo original)
-- Archivo: 46_SP_CONVENIOS_FIRMASMNTTO_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_firmas_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de firmas en ta_17_firmaconv
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_firmas_delete(
    p_recaudadora INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.ta_17_firmaconv WHERE recaudadora = p_recaudadora;
END;
$$;

-- ============================================

