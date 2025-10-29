-- Stored Procedure: sp_unidades_recoleccion_delete
-- Tipo: CRUD
-- Descripción: Elimina una unidad de recolección si no está referenciada en contratos.
-- Generado para formulario: ABC_Und_Recolec
-- Fecha: 2025-08-27 13:31:24

CREATE OR REPLACE FUNCTION sp_unidades_recoleccion_delete(
    p_ctrol integer
) RETURNS TABLE (status text) AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM ta_16_contratos WHERE ctrol_recolec = p_ctrol) THEN
        RETURN QUERY SELECT 'error: existen contratos con esta unidad';
        RETURN;
    END IF;
    DELETE FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT 'ok';
END;
$$ LANGUAGE plpgsql;