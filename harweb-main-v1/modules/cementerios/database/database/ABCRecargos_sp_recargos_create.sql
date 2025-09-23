-- Stored Procedure: sp_recargos_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo registro de recargo.
-- Generado para formulario: ABCRecargos
-- Fecha: 2025-08-28 17:38:53

CREATE OR REPLACE FUNCTION sp_recargos_create(
    p_axo integer,
    p_mes integer,
    p_porcentaje_parcial float,
    p_usuario integer
) RETURNS TABLE(result text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_13_recargosrcm WHERE axo = p_axo AND mes = p_mes;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'Ya existe el registro';
        RETURN;
    END IF;
    INSERT INTO ta_13_recargosrcm(axo, mes, porcentaje_parcial, porcentaje_global, usuario, fecha_mov)
    VALUES (p_axo, p_mes, p_porcentaje_parcial, 0, p_usuario, CURRENT_DATE);
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;