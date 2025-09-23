-- Stored Procedure: sp_tipos_aseo_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de aseo si no tiene contratos asociados.
-- Generado para formulario: ABC_Tipos_Aseo
-- Fecha: 2025-08-27 13:28:34

CREATE OR REPLACE FUNCTION sp_tipos_aseo_delete(
    p_ctrol_aseo INTEGER,
    p_usuario INTEGER
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    v_exists INTEGER;
    v_has_contracts INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de aseo';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_has_contracts FROM ta_16_contratos WHERE ctrol_aseo = p_ctrol_aseo;
    IF v_has_contracts > 0 THEN
        RETURN QUERY SELECT false, 'Existen contratos con este tipo de aseo. No se puede borrar.';
        RETURN;
    END IF;
    DELETE FROM ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo eliminado correctamente';
END;
$$ LANGUAGE plpgsql;