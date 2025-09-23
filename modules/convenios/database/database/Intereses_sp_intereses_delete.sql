-- Stored Procedure: sp_intereses_delete
-- Tipo: CRUD
-- Descripción: Elimina un registro de interés por año y mes.
-- Generado para formulario: Intereses
-- Fecha: 2025-08-27 14:47:29

CREATE OR REPLACE FUNCTION sp_intereses_delete(
    p_axo smallint,
    p_mes smallint
) RETURNS TABLE (
    axo smallint,
    mes smallint,
    deleted boolean
) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT p_axo, p_mes, false;
        RETURN;
    END IF;
    DELETE FROM ta_12_intereses WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT p_axo, p_mes, true;
END;
$$ LANGUAGE plpgsql;