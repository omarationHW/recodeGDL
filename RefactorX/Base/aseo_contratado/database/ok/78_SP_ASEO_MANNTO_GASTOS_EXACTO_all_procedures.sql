-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_GASTOS (EXACTO del archivo original)
-- Archivo: 78_SP_ASEO_MANNTO_GASTOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: sp_gastos_insert
-- Tipo: CRUD
-- Descripción: Inserta un registro de gastos en ta_16_gastos
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
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: MANNTO_GASTOS (EXACTO del archivo original)
-- Archivo: 78_SP_ASEO_MANNTO_GASTOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

