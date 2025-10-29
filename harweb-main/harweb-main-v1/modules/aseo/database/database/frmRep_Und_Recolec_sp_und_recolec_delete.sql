-- Stored Procedure: sp_und_recolec_delete
-- Tipo: CRUD
-- Descripción: Elimina una unidad de recolección si no está referenciada en contratos.
-- Generado para formulario: frmRep_Und_Recolec
-- Fecha: 2025-08-27 14:39:36

CREATE OR REPLACE FUNCTION sp_und_recolec_delete(p_ctrol INTEGER)
RETURNS TABLE (result TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_contratos WHERE ctrol_recolec = p_ctrol;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT 'NO SE PUEDE BORRAR: EXISTEN CONTRATOS';
        RETURN;
    END IF;
    DELETE FROM ta_16_unidades WHERE ctrol_recolec = p_ctrol;
    RETURN QUERY SELECT 'OK';
END;
$$ LANGUAGE plpgsql;