-- Stored Procedure: sp_tipos_aseo_create
-- Tipo: CRUD
-- Descripción: Alta de un nuevo tipo de aseo. Valida unicidad de tipo_aseo y existencia de cta_aplicacion.
-- Generado para formulario: ABC_Tipos_Aseo
-- Fecha: 2025-08-27 13:28:34

CREATE OR REPLACE FUNCTION sp_tipos_aseo_create(
    p_tipo_aseo VARCHAR(1),
    p_descripcion VARCHAR(80),
    p_cta_aplicacion INTEGER,
    p_usuario INTEGER
) RETURNS TABLE(success boolean, msg text) AS $$
DECLARE
    v_exists INTEGER;
    v_cta_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe el tipo de aseo';
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM ta_16_ctas_aplicacion WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe';
        RETURN;
    END IF;
    INSERT INTO ta_16_tipo_aseo (tipo_aseo, descripcion, cta_aplicacion, usuario_alta, fecha_alta)
    VALUES (p_tipo_aseo, p_descripcion, p_cta_aplicacion, p_usuario, NOW());
    RETURN QUERY SELECT true, 'Tipo de aseo creado correctamente';
END;
$$ LANGUAGE plpgsql;