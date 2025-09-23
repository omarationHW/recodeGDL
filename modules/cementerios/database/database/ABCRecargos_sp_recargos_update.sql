-- Stored Procedure: sp_recargos_update
-- Tipo: CRUD
-- Descripción: Actualiza un registro de recargo existente.
-- Generado para formulario: ABCRecargos
-- Fecha: 2025-08-28 17:38:53

CREATE OR REPLACE FUNCTION sp_recargos_update(
    p_axo integer,
    p_mes integer,
    p_porcentaje_parcial float,
    p_usuario integer
) RETURNS TABLE(result text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_13_recargosrcm WHERE axo = p_axo AND mes = p_mes;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT 'No existe el registro';
        RETURN;
    END IF;
    UPDATE ta_13_recargosrcm
    SET porcentaje_parcial = p_porcentaje_parcial,
        usuario = p_usuario,
        fecha_mov = CURRENT_DATE
    WHERE axo = p_axo AND mes = p_mes;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;