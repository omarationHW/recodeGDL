-- Stored Procedure: sp_insert_recargo
-- Tipo: CRUD
-- Descripción: Inserta un nuevo recargo de mantenimiento para un año y periodo.
-- Generado para formulario: RecargosMntto
-- Fecha: 2025-08-27 00:34:42

CREATE OR REPLACE FUNCTION sp_insert_recargo(p_axo integer, p_periodo integer, p_porcentaje numeric, p_id_usuario integer)
RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    existe integer;
BEGIN
    SELECT COUNT(*) INTO existe FROM ta_11_recargos WHERE axo = p_axo AND periodo = p_periodo;
    IF existe > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe un recargo para ese año y periodo.';
        RETURN;
    END IF;
    INSERT INTO ta_11_recargos(axo, periodo, porcentaje, fecha_alta, id_usuario)
    VALUES (p_axo, p_periodo, p_porcentaje, NOW(), p_id_usuario);
    RETURN QUERY SELECT true, 'Recargo insertado correctamente.';
END;
$$ LANGUAGE plpgsql;