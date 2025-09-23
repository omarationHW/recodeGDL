-- Stored Procedure: sp_update_recargo
-- Tipo: CRUD
-- Descripción: Actualiza el porcentaje de un recargo existente.
-- Generado para formulario: RecargosMntto
-- Fecha: 2025-08-27 00:34:42

CREATE OR REPLACE FUNCTION sp_update_recargo(p_axo integer, p_periodo integer, p_porcentaje numeric, p_id_usuario integer)
RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    existe integer;
BEGIN
    SELECT COUNT(*) INTO existe FROM ta_11_recargos WHERE axo = p_axo AND periodo = p_periodo;
    IF existe = 0 THEN
        RETURN QUERY SELECT false, 'No existe el recargo para ese año y periodo.';
        RETURN;
    END IF;
    UPDATE ta_11_recargos
    SET porcentaje = p_porcentaje, fecha_alta = NOW(), id_usuario = p_id_usuario
    WHERE axo = p_axo AND periodo = p_periodo;
    RETURN QUERY SELECT true, 'Recargo actualizado correctamente.';
END;
$$ LANGUAGE plpgsql;