-- Stored Procedure: catalogo_unidades
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de unidades de recolección para un ejercicio.
-- Generado para formulario: Contratos_Upd_Und
-- Fecha: 2025-08-27 14:29:48

CREATE OR REPLACE FUNCTION catalogo_unidades(p_ejercicio INTEGER)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad
    FROM ta_16_unidades
    WHERE ejercicio_recolec = p_ejercicio
    ORDER BY ctrol_recolec;
END;
$$ LANGUAGE plpgsql;