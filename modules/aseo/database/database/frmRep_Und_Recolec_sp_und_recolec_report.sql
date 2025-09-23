-- Stored Procedure: sp_und_recolec_report
-- Tipo: Report
-- Descripción: Devuelve el reporte de unidades de recolección para impresión/vista previa.
-- Generado para formulario: frmRep_Und_Recolec
-- Fecha: 2025-08-27 14:39:36

CREATE OR REPLACE FUNCTION sp_und_recolec_report(p_ejercicio INTEGER, p_order SMALLINT)
RETURNS TABLE (
    ctrol_recolec INTEGER,
    ejercicio_recolec SMALLINT,
    cve_recolec VARCHAR,
    descripcion VARCHAR,
    costo_unidad NUMERIC,
    costo_exed NUMERIC
) AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'SELECT ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed FROM ta_16_unidades WHERE ejercicio_recolec = %L ORDER BY %s',
        p_ejercicio,
        CASE p_order
            WHEN 1 THEN 'ctrol_recolec'
            WHEN 2 THEN 'cve_recolec'
            WHEN 3 THEN 'descripcion'
            WHEN 4 THEN 'costo_unidad'
            ELSE 'ctrol_recolec' END
    );
END;
$$ LANGUAGE plpgsql;