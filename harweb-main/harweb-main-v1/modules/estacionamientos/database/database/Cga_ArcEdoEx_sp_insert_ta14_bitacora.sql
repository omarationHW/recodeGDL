-- Stored Procedure: sp_insert_ta14_bitacora
-- Tipo: CRUD
-- Descripción: Inserta un registro en ta14_bitacora para registrar la carga de una remesa.
-- Generado para formulario: Cga_ArcEdoEx
-- Fecha: 2025-08-27 13:27:09

CREATE OR REPLACE FUNCTION sp_insert_ta14_bitacora(
    p_fecha_inicio date,
    p_fecha_fin date,
    p_fecha date,
    p_num_rem integer,
    p_cant_reg integer
) RETURNS TABLE(success boolean, msg text) AS $$
BEGIN
    INSERT INTO ta14_bitacora (
        id, tipo, fecha_inicio, fecha_fin, fecha, num_remesa, cant_reg
    ) VALUES (
        0, 'A', p_fecha_inicio, p_fecha_fin, p_fecha, p_num_rem, p_cant_reg
    );
    RETURN QUERY SELECT true, 'OK';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT false, 'Error al registrar en bitácora: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;