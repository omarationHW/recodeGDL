-- Stored Procedure: sp_unidades_recoleccion_create
-- Tipo: CRUD
-- Descripción: Crea una nueva unidad de recolección.
-- Generado para formulario: ABC_Und_Recolec
-- Fecha: 2025-08-27 13:31:24

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_create(
    p_ejercicio smallint,
    p_cve varchar(1),
    p_descripcion varchar(80),
    p_costo_unidad numeric(12,2),
    p_costo_exed numeric(12,2),
    p_usuario_id integer
) RETURNS TABLE (status text, ctrol_recolec integer) AS $$
DECLARE
    v_ctrol integer;
BEGIN
    -- Validar existencia
    IF EXISTS (SELECT 1 FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = p_cve) THEN
        RETURN QUERY SELECT 'error: clave ya existe', NULL;
        RETURN;
    END IF;
    -- Generar nuevo control
    SELECT COALESCE(MAX(ctrol_recolec),0)+1 INTO v_ctrol FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio;
    INSERT INTO ta_16_unidades (ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
    VALUES (v_ctrol, p_ejercicio, p_cve, p_descripcion, p_costo_unidad, p_costo_exed);
    RETURN QUERY SELECT 'ok', v_ctrol;
END;
$$ LANGUAGE plpgsql;