-- Stored Procedure: sp_contratos_upd_undc_actualizar_unidades
-- Tipo: CRUD
-- Descripción: Actualiza la cantidad de unidades de recolección en un contrato, recalcula importes de pagos, y registra el documento probatorio.
-- Generado para formulario: Contratos_Upd_UndC
-- Fecha: 2025-08-27 14:31:21

CREATE OR REPLACE FUNCTION sp_contratos_upd_undc_actualizar_unidades(
    p_control_contrato INTEGER,
    p_nueva_cantidad SMALLINT,
    p_ejercicio SMALLINT,
    p_mes SMALLINT,
    p_documento VARCHAR,
    p_descripcion_docto VARCHAR,
    p_usuario INTEGER
) RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_contrato RECORD;
    v_unidad RECORD;
    v_unidad_sig RECORD;
    v_importe NUMERIC;
    v_importe_sig NUMERIC;
    v_ejercicio_sig SMALLINT;
    v_dia SMALLINT := 1;
BEGIN
    -- Validaciones
    SELECT * INTO v_contrato FROM ta_16_contratos WHERE control_contrato = p_control_contrato AND status_vigencia = 'V';
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Contrato no encontrado o no vigente.';
        RETURN;
    END IF;
    IF p_nueva_cantidad IS NULL OR p_nueva_cantidad = 0 THEN
        RETURN QUERY SELECT FALSE, 'La cantidad debe ser mayor a cero.';
        RETURN;
    END IF;
    IF p_documento IS NULL OR length(trim(p_documento)) = 0 THEN
        RETURN QUERY SELECT FALSE, 'Debe proporcionar un documento probatorio.';
        RETURN;
    END IF;
    v_ejercicio_sig := p_ejercicio + 1;
    -- Buscar unidad actual
    SELECT * INTO v_unidad FROM ta_16_unidades WHERE ejercicio_recolec = p_ejercicio AND cve_recolec = v_contrato.cve_recolec LIMIT 1;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No existe tarifa de unidad para el ejercicio actual.';
        RETURN;
    END IF;
    -- Buscar unidad siguiente
    SELECT * INTO v_unidad_sig FROM ta_16_unidades WHERE ejercicio_recolec = v_ejercicio_sig AND cve_recolec = v_contrato.cve_recolec LIMIT 1;
    -- Actualizar contrato
    UPDATE ta_16_contratos SET cantidad_recolec = p_nueva_cantidad, usuario = p_usuario WHERE control_contrato = p_control_contrato;
    -- Actualizar pagos del ejercicio actual
    v_importe := p_nueva_cantidad * v_unidad.costo_unidad;
    UPDATE ta_16_pagos SET exedencias = p_nueva_cantidad, importe = v_importe
      WHERE control_contrato = p_control_contrato
        AND aso_mes_pago >= make_date(p_ejercicio, p_mes, v_dia)
        AND status_vigencia = 'V';
    -- Actualizar pagos del ejercicio siguiente si existe tarifa
    IF FOUND AND v_unidad_sig IS NOT NULL THEN
        v_importe_sig := p_nueva_cantidad * v_unidad_sig.costo_unidad;
        UPDATE ta_16_pagos SET importe = v_importe_sig
          WHERE control_contrato = p_control_contrato
            AND aso_mes_pago >= make_date(v_ejercicio_sig, 1, v_dia)
            AND status_vigencia = 'V';
    END IF;
    -- Insertar en historial de contratos
    INSERT INTO ta_16_contratos_h (control, control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (DEFAULT, p_control_contrato, p_documento, p_descripcion_docto, p_usuario, now());
    RETURN QUERY SELECT TRUE, 'Unidades actualizadas correctamente.';
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, 'Error al actualizar unidades: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;