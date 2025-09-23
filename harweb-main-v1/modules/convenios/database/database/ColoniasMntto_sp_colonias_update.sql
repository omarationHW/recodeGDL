-- Stored Procedure: sp_colonias_update
-- Tipo: CRUD
-- Descripción: Actualiza una colonia existente en ta_17_colonias
-- Generado para formulario: ColoniasMntto
-- Fecha: 2025-08-27 14:07:19

CREATE OR REPLACE FUNCTION sp_colonias_update(
    p_colonia integer,
    p_descripcion varchar,
    p_id_rec integer,
    p_id_zona integer,
    p_col_obra94 integer,
    p_id_usuario integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_17_colonias WHERE colonia = p_colonia;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'La colonia no existe';
        RETURN;
    END IF;
    UPDATE ta_17_colonias
    SET descripcion = p_descripcion,
        id_rec = p_id_rec,
        id_zona = p_id_zona,
        col_obra94 = p_col_obra94,
        id_usuario = p_id_usuario,
        fecha_actual = CURRENT_TIMESTAMP
    WHERE colonia = p_colonia;
    RETURN QUERY SELECT true, 'Colonia actualizada correctamente';
END;
$$ LANGUAGE plpgsql;