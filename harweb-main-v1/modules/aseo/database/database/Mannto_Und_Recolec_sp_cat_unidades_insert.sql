-- Stored Procedure: sp_cat_unidades_insert
-- Tipo: CRUD
-- Descripción: Inserta una nueva unidad de recolección si no existe la clave para el ejercicio.
-- Generado para formulario: Mannto_Und_Recolec
-- Fecha: 2025-08-27 14:54:11

CREATE OR REPLACE FUNCTION sp_cat_unidades_insert(
    p_ejercicio SMALLINT,
    p_cve CHAR(1),
    p_descripcion VARCHAR(80),
    p_costo NUMERIC(12,2),
    p_costo_exed NUMERIC(12,2)
) RETURNS TABLE(success BOOLEAN, message TEXT, ctrol_recolec INTEGER) AS $$
DECLARE
    v_exists INTEGER;
    v_new_id INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_cve;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT FALSE, 'Ya existe una clave para ese ejercicio', NULL;
        RETURN;
    END IF;
    INSERT INTO ta_16_unidades (ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (p_ejercicio, p_cve, p_descripcion, p_costo, p_costo_exed)
    RETURNING ctrol_recolec INTO v_new_id;
    RETURN QUERY SELECT TRUE, 'Unidad creada correctamente', v_new_id;
END;
$$ LANGUAGE plpgsql;