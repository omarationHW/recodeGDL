-- Stored Procedure: sp_cat_tipos_aseo_update
-- Tipo: CRUD
-- Descripción: Actualiza un tipo de aseo existente.
-- Generado para formulario: Mannto_Tipos_Aseo
-- Fecha: 2025-08-27 14:50:41

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_update(
    p_tipo_aseo varchar(1),
    p_descripcion varchar(80),
    p_cta_aplicacion integer
) RETURNS TABLE(success boolean, message text) AS $$
DECLARE
    v_exists integer;
    v_cta_exists integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'Tipo de aseo no existe';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM ta_12_cuentas WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe';
        RETURN;
    END IF;
    UPDATE ta_16_tipo_aseo SET descripcion = p_descripcion, cta_aplicacion = p_cta_aplicacion
    WHERE tipo_aseo = p_tipo_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo actualizado correctamente';
END;
$$ LANGUAGE plpgsql;