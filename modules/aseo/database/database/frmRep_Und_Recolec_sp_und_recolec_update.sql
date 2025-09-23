-- Stored Procedure: sp_und_recolec_update
-- Tipo: CRUD
-- Descripción: Actualiza una unidad de recolección existente.
-- Generado para formulario: frmRep_Und_Recolec
-- Fecha: 2025-08-27 14:39:36

CREATE OR REPLACE FUNCTION sp_und_recolec_update(
    p_ctrol INTEGER,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE (result TEXT) AS $$
BEGIN
    UPDATE ta_16_unidades
    SET descripcion = p_descripcion,
        costo_unidad = p_costo_unidad,
        costo_exed = p_costo_exed
    WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;