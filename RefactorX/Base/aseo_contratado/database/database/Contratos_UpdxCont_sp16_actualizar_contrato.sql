-- Stored Procedure: sp16_actualizar_contrato
-- Tipo: CRUD
-- Descripción: Actualiza los datos principales de un contrato y registra el documento probatorio.
-- Generado para formulario: Contratos_UpdxCont
-- Fecha: 2025-08-27 14:22:10

CREATE OR REPLACE FUNCTION sp16_actualizar_contrato(
    p_control_contrato INTEGER,
    p_num_empresa INTEGER,
    p_ctrol_emp INTEGER,
    p_domicilio VARCHAR,
    p_sector VARCHAR,
    p_ctrol_zona INTEGER,
    p_id_rec INTEGER,
    p_documento VARCHAR,
    p_descripcion_docto VARCHAR,
    p_usuario INTEGER
) RETURNS TABLE (updated BOOLEAN, message TEXT) AS $$
DECLARE
    v_exists INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_exists FROM ta_16_contratos WHERE control_contrato = p_control_contrato;
    IF v_exists = 0 THEN
        RETURN QUERY SELECT FALSE, 'Contrato no encontrado';
        RETURN;
    END IF;
    UPDATE ta_16_contratos
    SET num_empresa = p_num_empresa,
        ctrol_emp = p_ctrol_emp,
        domicilio = p_domicilio,
        sector = p_sector,
        ctrol_zona = p_ctrol_zona,
        id_rec = p_id_rec,
        cve = 'C',
        usuario = p_usuario
    WHERE control_contrato = p_control_contrato;
    INSERT INTO ta_16_contratos_h (control, control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (DEFAULT, p_control_contrato, p_documento, p_descripcion_docto, p_usuario, CURRENT_TIMESTAMP);
    RETURN QUERY SELECT TRUE, 'Contrato actualizado correctamente';
END;
$$ LANGUAGE plpgsql;