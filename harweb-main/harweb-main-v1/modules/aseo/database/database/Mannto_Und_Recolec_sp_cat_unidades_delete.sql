-- Stored Procedure: sp_cat_unidades_delete
-- Tipo: CRUD
-- Descripción: Elimina una unidad de recolección si no tiene contratos asociados.
-- Generado para formulario: Mannto_Und_Recolec
-- Fecha: 2025-08-27 14:54:11

CREATE OR REPLACE FUNCTION sp_cat_unidades_delete(p_ctrol_recolec INTEGER)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_contratos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_contratos FROM ta_16_contratos WHERE ctrol_recolec = p_ctrol_recolec;
    IF v_contratos > 0 THEN
        RETURN QUERY SELECT FALSE, 'Existen contratos asociados a esta unidad. No se puede eliminar.';
        RETURN;
    END IF;
    DELETE FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol_recolec;
    RETURN QUERY SELECT TRUE, 'Unidad eliminada correctamente';
END;
$$ LANGUAGE plpgsql;