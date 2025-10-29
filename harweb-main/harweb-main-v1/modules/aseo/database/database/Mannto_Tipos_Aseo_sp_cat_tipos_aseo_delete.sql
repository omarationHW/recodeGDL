-- Stored Procedure: sp_cat_tipos_aseo_delete
-- Tipo: CRUD
-- Descripción: Elimina un tipo de aseo si no tiene contratos asociados.
-- Generado para formulario: Mannto_Tipos_Aseo
-- Fecha: 2025-08-27 14:50:41

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_delete(p_tipo_aseo varchar(1))
RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_ctrol integer;
    v_contratos integer;
BEGIN
    SELECT ctrol_aseo INTO v_ctrol FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_ctrol IS NULL THEN
        RETURN QUERY SELECT false, 'Tipo de aseo no existe';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_contratos FROM ta_16_contratos WHERE ctrol_aseo = v_ctrol;
    IF v_contratos > 0 THEN
        RETURN QUERY SELECT false, 'Existen contratos con este tipo de aseo. No se puede eliminar.';
        RETURN;
    END IF;
    DELETE FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo eliminado correctamente';
END;
$$ LANGUAGE plpgsql;