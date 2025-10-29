-- Stored Procedure: actualizar_unidades_contrato
-- Tipo: CRUD
-- Descripción: Actualiza las unidades de recolección de un contrato, ajusta pagos y guarda histórico.
-- Generado para formulario: Contratos_Upd_Und
-- Fecha: 2025-08-27 14:29:48

CREATE OR REPLACE FUNCTION actualizar_unidades_contrato(
    p_control_contrato INTEGER,
    p_ctrol_recolec INTEGER,
    p_cantidad SMALLINT,
    p_ejercicio INTEGER,
    p_mes INTEGER,
    p_documento VARCHAR,
    p_descripcion VARCHAR,
    p_user_id INTEGER
) RETURNS TABLE(status INTEGER, leyenda TEXT) AS $$
DECLARE
    v_importe NUMERIC;
    v_importe_sig NUMERIC;
    v_ejer_sig INTEGER;
    v_dia INTEGER := 1;
    v_unidades SMALLINT;
    v_costo NUMERIC;
    v_costo_sig NUMERIC;
BEGIN
    -- Validaciones básicas
    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        RETURN QUERY SELECT 1, 'Cantidad inválida.';
        RETURN;
    END IF;
    IF p_documento IS NULL OR length(p_documento) < 3 THEN
        RETURN QUERY SELECT 2, 'Documento requerido.';
        RETURN;
    END IF;
    v_ejer_sig := p_ejercicio + 1;
    -- Obtener costo unidad actual y siguiente
    SELECT costo_unidad INTO v_costo FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND ctrol_recolec = p_ctrol_recolec LIMIT 1;
    SELECT costo_unidad INTO v_costo_sig FROM ta_16_unidades WHERE ejercicio_recolec = v_ejer_sig AND ctrol_recolec = p_ctrol_recolec LIMIT 1;
    IF v_costo IS NULL THEN
        RETURN QUERY SELECT 3, 'No existe costo de unidad para el ejercicio actual.';
        RETURN;
    END IF;
    -- Actualizar contrato
    UPDATE ta_16_contratos
    SET ctrol_recolec = p_ctrol_recolec,
        cantidad_recolec = p_cantidad,
        usuario = p_user_id
    WHERE control_contrato = p_control_contrato;
    -- Actualizar pagos del ejercicio actual
    v_importe := p_cantidad * v_costo;
    UPDATE ta_16_pagos
    SET importe = v_importe
    WHERE control_contrato = p_control_contrato
      AND aso_mes_pago >= make_date(p_ejercicio, p_mes, v_dia)
      AND status_vigencia = 'V';
    -- Actualizar pagos del ejercicio siguiente
    IF v_costo_sig IS NOT NULL THEN
        v_importe_sig := p_cantidad * v_costo_sig;
        UPDATE ta_16_pagos
        SET importe = v_importe_sig
        WHERE control_contrato = p_control_contrato
          AND aso_mes_pago >= make_date(v_ejer_sig, 1, v_dia)
          AND status_vigencia = 'V';
    END IF;
    -- Insertar histórico
    INSERT INTO ta_16_contratos_h (control, control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (DEFAULT, p_control_contrato, p_documento, p_descripcion, p_user_id, now());
    RETURN QUERY SELECT 0, 'Actualización exitosa.';
END;
$$ LANGUAGE plpgsql;