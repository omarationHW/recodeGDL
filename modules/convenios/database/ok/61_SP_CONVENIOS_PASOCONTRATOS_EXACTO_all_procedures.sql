-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: PASOCONTRATOS (EXACTO del archivo original)
-- Archivo: 61_SP_CONVENIOS_PASOCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: spd_17_limpia_paso
-- Tipo: CRUD
-- Descripción: Limpia la tabla de paso de contratos (ta_17_paso_cont)
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE spd_17_limpia_paso()
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE TABLE ta_17_paso_cont RESTART IDENTITY;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: PASOCONTRATOS (EXACTO del archivo original)
-- Archivo: 61_SP_CONVENIOS_PASOCONTRATOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

