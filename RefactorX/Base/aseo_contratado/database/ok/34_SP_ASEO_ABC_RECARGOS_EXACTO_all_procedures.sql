-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_RECARGOS (EXACTO del archivo original)
-- Archivo: 34_SP_ASEO_ABC_RECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 1/4: sp_recargos_list
-- Tipo: Catalog
-- Descripción: Lista todos los recargos, opcionalmente por año.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_list(p_year integer DEFAULT NULL)
RETURNS TABLE (
    aso_mes_recargo date,
    porc_recargo float,
    porc_multa float
) AS $$
BEGIN
    RETURN QUERY
    SELECT aso_mes_recargo, porc_recargo, porc_multa
    FROM public.ta_16_recargos
    WHERE (p_year IS NULL OR EXTRACT(YEAR FROM aso_mes_recargo) = p_year)
    ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_RECARGOS (EXACTO del archivo original)
-- Archivo: 34_SP_ASEO_ABC_RECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: sp_recargos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de recargo existente.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_update(p_aso_mes_recargo date, p_porc_recargo float, p_porc_multa float)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM public.ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el recargo para ese periodo.';
        RETURN;
    END IF;
    UPDATE public.ta_16_recargos
    SET porc_recargo = p_porc_recargo, porc_multa = p_porc_multa
    WHERE aso_mes_recargo = p_aso_mes_recargo;
    RETURN QUERY SELECT true, 'Recargo actualizado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ABC_RECARGOS (EXACTO del archivo original)
-- Archivo: 34_SP_ASEO_ABC_RECARGOS_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

