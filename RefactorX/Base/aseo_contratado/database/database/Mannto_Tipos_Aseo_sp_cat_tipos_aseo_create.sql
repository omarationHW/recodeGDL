-- Stored Procedure: sp_cat_tipos_aseo_create
-- Tipo: CRUD
-- Descripción: Crea un nuevo tipo de aseo. Valida unicidad y existencia de cuenta de aplicación.
-- Generado para formulario: Mannto_Tipos_Aseo
-- Fecha: 2025-08-27 14:50:41

CREATE OR REPLACE FUNCTION sp_cat_tipos_aseo_create(
    p_tipo_aseo varchar(1),
    p_descripcion varchar(80),
    p_cta_aplicacion integer
) RETURNS TABLE(success boolean, message text, ctrol_aseo integer) AS $$
DECLARE
    v_exists integer;
    v_cta_exists integer;
    v_new_ctrol integer;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_tipo_aseo WHERE tipo_aseo = p_tipo_aseo;
    IF v_exists > 0 THEN
        RETURN QUERY SELECT false, 'Ya existe el tipo de aseo', NULL;
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_cta_exists FROM ta_12_cuentas WHERE cta_aplicacion = p_cta_aplicacion;
    IF v_cta_exists = 0 THEN
        RETURN QUERY SELECT false, 'La cuenta de aplicación no existe', NULL;
        RETURN;
    END IF;
    SELECT COALESCE(MAX(ctrol_aseo),0)+1 INTO v_new_ctrol FROM ta_16_tipo_aseo;
    INSERT INTO ta_16_tipo_aseo (ctrol_aseo, tipo_aseo, descripcion, cta_aplicacion)
    VALUES (v_new_ctrol, p_tipo_aseo, p_descripcion, p_cta_aplicacion);
    RETURN QUERY SELECT true, 'Tipo de aseo creado correctamente', v_new_ctrol;
END;
$$ LANGUAGE plpgsql;