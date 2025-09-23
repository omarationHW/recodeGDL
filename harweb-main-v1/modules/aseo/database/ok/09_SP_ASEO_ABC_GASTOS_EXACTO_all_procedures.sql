-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_Gastos (EXACTO del archivo original)
-- Archivo: 09_SP_ASEO_ABC_GASTOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-09
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_gastos_insert
-- Tipo: Catalog
-- Descripción: Inserta un nuevo registro de gastos (solo debe existir uno)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_gastos_insert(
    p_sdzmg NUMERIC,
    p_porc1_req NUMERIC,
    p_porc2_embargo NUMERIC,
    p_porc3_secuestro NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.ta_16_gastos (sdzmg, porc1_req, porc2_embargo, porc3_secuestro)
    VALUES (p_sdzmg, p_porc1_req, p_porc2_embargo, p_porc3_secuestro);
END;
$$;

-- ============================================

-- SP 2/2: sp_gastos_delete_all
-- Tipo: Catalog
-- Descripción: Elimina todos los registros de gastos (solo debe haber uno)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE sp_gastos_delete_all()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.ta_16_gastos;
END;
$$;

-- ============================================