-- Stored Procedure: sp_cat_unidades_list
-- Tipo: Catalog
-- Descripción: Lista todas las unidades de recolección para un ejercicio dado.
-- Generado para formulario: Menu
-- Fecha: 2025-08-27 14:57:35

CREATE OR REPLACE FUNCTION sp_cat_unidades_list(p_ejercicio INTEGER)
RETURNS TABLE(
    id SERIAL,
    ejercicio INTEGER,
    clave VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC,
    costo_exed NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT id, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY id;
END;
$$ LANGUAGE plpgsql;