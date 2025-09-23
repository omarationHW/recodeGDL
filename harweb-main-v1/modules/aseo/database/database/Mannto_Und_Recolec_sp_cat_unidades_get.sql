-- Stored Procedure: sp_cat_unidades_get
-- Tipo: Catalog
-- Descripción: Obtiene una unidad de recolección por su control.
-- Generado para formulario: Mannto_Und_Recolec
-- Fecha: 2025-08-27 14:54:11

CREATE OR REPLACE FUNCTION sp_cat_unidades_get(p_ctrol_recolec INTEGER)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec CHAR(1),
    descripcion VARCHAR(80),
    costo_unidad NUMERIC(12,2),
    costo_exed NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed
    FROM ta_16_unidades
    WHERE ctrol_recolec = p_ctrol_recolec;
END;
$$ LANGUAGE plpgsql;