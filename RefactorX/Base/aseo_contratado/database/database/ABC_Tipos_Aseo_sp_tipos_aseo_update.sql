-- Stored Procedure: sp_tipos_aseo_update
-- Tipo: CRUD
-- Descripción: Actualiza un tipo de aseo existente. Valida existencia y cuenta de aplicación.
-- Generado para formulario: ABC_Tipos_Aseo
-- Fecha: 2025-08-27 13:28:34

CREATE OR REPLACE FUNCTION sp_tipos_aseo_update(
    p_ctrol_aseo INTEGER,
    p_tipo_aseo VARCHAR(1),
    p_descripcion VARCHAR(80),
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    v_exists INTEGER;
    v_cta_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE ctrol_aseo = p_ctrol_aseo;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT false, 'No existe el tipo de aseo';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM ta_16_ctas_aplicacion WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe';
        RETURN;
    END IF;
    UPDATE ta_16_tipo_aseo
    SET tipo_aseo = p_tipo_aseo,
        descripcion = p_descripcion,
        cta_aplicacion = p_cta_aplicacion,
        usuario_mod = p_usuario,
        fecha_mod = NOW()
    WHERE ctrol_aseo = p_ctrol_aseo;
    RETURN QUERY SELECT true, 'Tipo de aseo actualizado correctamente';
END;
$$ LANGUAGE plpgsql;