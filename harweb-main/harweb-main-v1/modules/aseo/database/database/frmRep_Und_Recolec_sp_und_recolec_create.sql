-- Stored Procedure: sp_und_recolec_create
-- Tipo: CRUD
-- Descripción: Crea una nueva unidad de recolección.
-- Generado para formulario: frmRep_Und_Recolec
-- Fecha: 2025-08-27 14:39:36

CREATE OR REPLACE FUNCTION sp_und_recolec_create(
    p_ejercicio SMALLINT,
    p_cve VARCHAR,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE (result TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_cve;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'YA EXISTE';
        RETURN;
    END IF;
    INSERT INTO ta_16_unidades (ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (p_ejercicio, p_cve, p_descripcion, p_costo_unidad, p_costo_exed);
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;