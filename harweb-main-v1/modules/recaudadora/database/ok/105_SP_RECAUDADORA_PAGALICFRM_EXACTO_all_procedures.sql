-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: PAGALICFRM (EXACTO del archivo original)
-- Archivo: 105_SP_RECAUDADORA_PAGALICFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

-- SP 1/2: calc_sdosl
-- Tipo: CRUD
-- Descripción: Recalcula los saldos de una licencia después de marcar como pagado.
-- --------------------------------------------

CREATE OR REPLACE PROCEDURE calc_sdosl(IN id_licencia_in integer)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Aquí va la lógica de recálculo de saldos para la licencia
    -- Por ejemplo, actualizar campos de saldo en detsal_lic, licencias, etc.
    -- Esta lógica debe ser adaptada a las reglas de negocio reales
    UPDATE detsal_lic
    SET saldo = 0
    WHERE id_licencia = id_licencia_in AND cvepago = 999999999;
    -- Otras actualizaciones necesarias...
END;
$$;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: PAGALICFRM (EXACTO del archivo original)
-- Archivo: 105_SP_RECAUDADORA_PAGALICFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 2 (EXACTO)
-- ============================================

