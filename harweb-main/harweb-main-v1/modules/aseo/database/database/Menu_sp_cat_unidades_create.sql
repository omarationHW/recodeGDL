-- Stored Procedure: sp_cat_unidades_create
-- Tipo: Catalog
-- Descripción: Crea una nueva unidad de recolección.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_unidades_create(
    p_ejercicio INTEGER,
    p_clave VARCHAR,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE(result TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_clave;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'ERROR: Ya existe la clave para ese ejercicio';
        RETURN;
    END IF;
    INSERT INTO ta_16_unidades (ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (p_ejercicio, p_clave, p_descripcion, p_costo_unidad, p_costo_exed);
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;