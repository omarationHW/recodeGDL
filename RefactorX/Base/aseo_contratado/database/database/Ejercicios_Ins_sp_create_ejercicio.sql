-- Stored Procedure: sp_create_ejercicio
-- Tipo: Catalog
-- Descripción: Crea un nuevo ejercicio en la tabla ta_16_ejercicios si no existe.
-- Generado para formulario: Ejercicios_Ins
-- Fecha: 2025-08-27 14:36:01

CREATE OR REPLACE FUNCTION sp_create_ejercicio(p_ejercicio INTEGER)
RETURNS TEXT AS $$
DECLARE
    existe INTEGER;
BEGIN
    SELECT 1 INTO existe FROM ta_16_ejercicios WHERE ejercicio = p_ejercicio;
    IF existe IS NOT NULL THEN
        RETURN 'YA EXISTE EL EJERCICIO';
    END IF;
    INSERT INTO ta_16_ejercicios (ejercicio, fecha_hora_alta) VALUES (p_ejercicio, NOW());
    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;