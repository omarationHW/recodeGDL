-- Stored Procedure: sp_cat_unidades_update
-- Tipo: CRUD
-- Descripción: Actualiza una unidad de recolección por su control.
-- Generado para formulario: Mannto_Und_Recolec
-- Fecha: 2025-08-27 14:54:11

CREATE OR REPLACE FUNCTION sp_cat_unidades_update(
    p_ctrol_recolec INTEGER,
    p_descripcion VARCHAR(80),
    p_costo NUMERIC(12,2),
    p_costo_exed NUMERIC(12,2)
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol_recolec;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'No existe la unidad', NULL;
        RETURN;
    END IF;
    UPDATE ta_16_unidades
    SET descripcion = p_descripcion, costo_unidad = p_costo, costo_exed = p_costo_exed
    WHERE ctrol_recolec = p_ctrol_recolec;
    RETURN QUERY SELECT TRUE, 'Unidad actualizada correctamente';
END;
$$ LANGUAGE plpgsql;