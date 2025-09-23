-- Stored Procedure: sp_unidades_recoleccion_list
-- Tipo: Catalog
-- Descripción: Lista todas las unidades de recolección para un ejercicio dado.
-- Generado para formulario: ABC_Und_Recolec
-- Fecha: 2025-08-27 13:31:24

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_list(p_ejercicio integer)
RETURNS TABLE (
    ctrol_recolec integer,
    ejercicio_recolec smallint,
    cve_recolec varchar(1),
    descripcion varchar(80),
    costo_unidad numeric(12,2),
    costo_exed numeric(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY ejercicio_recolec, cve_recolec;
END;
$$ LANGUAGE plpgsql;