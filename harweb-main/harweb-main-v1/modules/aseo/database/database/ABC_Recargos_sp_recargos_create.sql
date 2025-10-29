-- Stored Procedure: sp_recargos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de recargo si no existe para el periodo.
-- Generado para formulario: ABC_Recargos
-- Fecha: 2025-08-27 13:25:47

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