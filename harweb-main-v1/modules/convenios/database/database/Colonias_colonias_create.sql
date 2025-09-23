-- Stored Procedure: colonias_create
-- Tipo: CRUD
-- Descripción: Inserta una nueva colonia en el catálogo.
-- Generado para formulario: Colonias
-- Fecha: 2025-08-27 14:05:29

CREATE OR REPLACE FUNCTION colonias_create(
    p_colonia SMALLINT,
    p_descripcion VARCHAR,
    p_id_rec SMALLINT,
    p_id_zona INTEGER,
    p_col_obra94 SMALLINT,
    p_id_usuario INTEGER
) RETURNS TABLE (success BOOLEAN, message TEXT) AS $$
BEGIN
    INSERT INTO ta_17_colonias (colonia, descripcion, id_rec, id_zona, col_obra94, id_usuario, fecha_actual)
    VALUES (p_colonia, p_descripcion, p_id_rec, p_id_zona, p_col_obra94, p_id_usuario, now());
    RETURN QUERY SELECT TRUE, 'Colonia creada correctamente';
EXCEPTION WHEN unique_violation THEN
    RETURN QUERY SELECT FALSE, 'Ya existe una colonia con ese código';
WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, SQLERRM;
END;
$$ LANGUAGE plpgsql;