-- Stored Procedure: sp_colonias_create
-- Tipo: CRUD
-- Descripción: Inserta una nueva colonia en ta_17_colonias
-- Generado para formulario: ColoniasMntto
-- Fecha: 2025-08-27 14:07:19

CREATE OR REPLACE FUNCTION sp_colonias_create(
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
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'La colonia ya existe';
        RETURN;
    END IF;
    INSERT INTO ta_17_colonias (colonia, descripcion, id_rec, id_zona, col_obra94, id_usuario, fecha_actual)
    VALUES (p_colonia, p_descripcion, p_id_rec, p_id_zona, p_col_obra94, p_id_usuario, CURRENT_TIMESTAMP);
    RETURN QUERY SELECT true, 'Colonia insertada correctamente';
END;
$$ LANGUAGE plpgsql;