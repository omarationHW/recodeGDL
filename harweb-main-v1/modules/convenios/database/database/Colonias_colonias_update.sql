-- Stored Procedure: colonias_update
-- Tipo: CRUD
-- Descripción: Actualiza los datos de una colonia existente.
-- Generado para formulario: Colonias
-- Fecha: 2025-08-27 14:05:29

CREATE OR REPLACE FUNCTION colonias_update(
    p_colonia SMALLINT,
    p_descripcion VARCHAR,
    p_id_rec SMALLINT,
    p_id_zona INTEGER,
    p_col_obra94 SMALLINT,
    p_id_usuario INTEGER
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
BEGIN
    UPDATE ta_17_colonias
    SET descripcion = p_descripcion,
        id_rec = p_id_rec,
        id_zona = p_id_zona,
        col_obra94 = p_col_obra94,
        id_usuario = p_id_usuario,
        fecha_actual = now()
    WHERE colonia = p_colonia;
    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Colonia actualizada correctamente';
    ELSE
        RETURN QUERY SELECT FALSE, 'Colonia no encontrada';
    END IF;
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;