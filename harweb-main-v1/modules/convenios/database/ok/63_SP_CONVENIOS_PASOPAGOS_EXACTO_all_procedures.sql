-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: PASOPAGOS (EXACTO del archivo original)
-- Archivo: 63_SP_CONVENIOS_PASOPAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: spd_17_b_p400cont
-- Tipo: CRUD
-- Descripción: Limpia la tabla temporal de paso de pagos de contratos AS/400
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE spd_17_b_p400cont()
LANGUAGE plpgsql
AS $$
BEGIN
  TRUNCATE TABLE ta_17_paso_p_400 RESTART IDENTITY;
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - CONVENIOS
-- Formulario: PASOPAGOS (EXACTO del archivo original)
-- Archivo: 63_SP_CONVENIOS_PASOPAGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

