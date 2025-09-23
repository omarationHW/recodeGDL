-- Stored Procedure: sp_unidades_recoleccion_update
-- Tipo: CRUD
-- Descripción: Actualiza una unidad de recolección existente.
-- Generado para formulario: ABC_Und_Recolec
-- Fecha: 2025-08-27 13:31:24

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_update(
    p_ctrol integer,
    p_ejercicio smallint,
    p_cve varchar(1),
    p_descripcion varchar(80),
    p_costo_unidad numeric(12,2),
    p_costo_exed numeric(12,2),
    p_usuario_id integer
) RETURNS TABLE (status text) AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol) THEN
        RETURN QUERY SELECT 'error: unidad no existe';
        RETURN;
    END IF;
    UPDATE ta_16_unidades
    SET ejercicio_recolec = p_ejercicio,
        cve_recolec = p_cve,
        descripcion = p_descripcion,
        costo_unidad = p_costo_unidad,
        costo_exed = p_costo_exed
    WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT 'ok';
END;
$$ LANGUAGE plpgsql;