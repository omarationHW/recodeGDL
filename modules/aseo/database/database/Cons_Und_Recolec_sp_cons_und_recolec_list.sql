-- Stored Procedure: sp_cons_und_recolec_list
-- Tipo: Catalog
-- Descripción: Devuelve la lista de unidades de recolección filtradas por ejercicio y ordenadas según el campo indicado.
-- Generado para formulario: Cons_Und_Recolec
-- Fecha: 2025-08-27 14:05:27

CREATE OR REPLACE FUNCTION sp_cons_und_recolec_list(p_ejercicio INTEGER, p_order TEXT DEFAULT 'ctrol_recolec')
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec VARCHAR(1),
    descripcion VARCHAR(80),
    costo_unidad NUMERIC(12,2),
    costo_exed NUMERIC(12,2)
) AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed FROM ta_16_unidades WHERE ejercicio_recolec = $1 ORDER BY %I', p_order
    ) USING p_ejercicio;
END;
$$ LANGUAGE plpgsql;