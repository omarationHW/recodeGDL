-- Stored Procedure: sp_cat_unidades_update
-- Tipo: Catalog
-- Descripción: Actualiza una unidad de recolección existente.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_unidades_update(
    p_id INTEGER,
    p_descripcion VARCHAR,
    p_costo_unidad NUMERIC,
    p_costo_exed NUMERIC
) RETURNS TABLE(result TEXT) AS $$
BEGIN
    UPDATE ta_16_unidades
    SET descripcion = p_descripcion, costo_unidad = p_costo_unidad, costo_exed = p_costo_exed
    WHERE id = p_id;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;