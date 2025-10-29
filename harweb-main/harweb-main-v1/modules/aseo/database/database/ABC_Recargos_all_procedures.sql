-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ABC_Recargos
-- Generado: 2025-08-27 13:25:47
-- Total SPs: 4
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
    FROM ta_16_recargos
    WHERE (p_year IS NULL OR EXTRACT(YEAR FROM aso_mes_recargo) = p_year)
    ORDER BY aso_mes_recargo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: sp_recargos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de recargo si no existe para el periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_create(p_aso_mes_recargo date, p_porc_recargo float, p_porc_multa float)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un recargo para ese periodo.';
        RETURN;
    END IF;
    INSERT INTO ta_16_recargos (aso_mes_recargo, porc_recargo, porc_multa)
    VALUES (p_aso_mes_recargo, p_porc_recargo, p_porc_multa);
    RETURN QUERY SELECT true, 'Recargo creado correctamente.';
END;
$$ LANGUAGE plpgsql;

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
    SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el recargo para ese periodo.';
        RETURN;
    END IF;
    UPDATE ta_16_recargos
    SET porc_recargo = p_porc_recargo, porc_multa = p_porc_multa
    WHERE aso_mes_recargo = p_aso_mes_recargo;
    RETURN QUERY SELECT true, 'Recargo actualizado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/4: sp_recargos_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de recargo por periodo.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_recargos_delete(p_aso_mes_recargo date)
RETURNS TABLE (success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el recargo para ese periodo.';
        RETURN;
    END IF;
    DELETE FROM ta_16_recargos WHERE aso_mes_recargo = p_aso_mes_recargo;
    RETURN QUERY SELECT true, 'Recargo eliminado correctamente.';
END;
$$ LANGUAGE plpgsql;

-- ============================================

