-- Stored Procedure: sp_recargos_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de recargo por periodo.
-- Generado para formulario: ABC_Recargos
-- Fecha: 2025-08-27 13:25:47

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