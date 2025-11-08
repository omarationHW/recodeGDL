-- Stored Procedure: sp16_update_inicio_obligacion
-- Tipo: CRUD
-- Descripción: Actualiza el inicio de obligación de un contrato, elimina pagos anteriores, inserta nuevos pagos, actualiza el contrato y registra el documento probatorio.
-- Generado para formulario: Contratos_Upd_IniObl
-- Fecha: 2025-08-27 14:26:21

-- PostgreSQL stored procedure for updating inicio de obligación
CREATE OR REPLACE FUNCTION sp16_update_inicio_obligacion(
    p_control_contrato integer,
    p_aso_mes_oblig date,
    p_usuario integer,
    p_docto text,
    p_descrip text,
    p_ctrol_recolec integer
) RETURNS TABLE(status integer, leyenda text) AS $$
DECLARE
    v_unidades integer;
    v_costo_unidad numeric;
    v_costo_unidad_sig numeric;
    v_ejer integer;
    v_ejer_sig integer;
    v_mes integer;
    v_dia integer := 1;
    v_importe numeric;
    v_importe_sig numeric;
    v_mes_sig integer;
    v_rec integer;
    v_usuario integer := p_usuario;
BEGIN
    -- Validar existencia del contrato
    IF NOT EXISTS (SELECT 1 FROM ta_16_contratos WHERE control_contrato = p_control_contrato AND status_vigencia = 'V') THEN
        RETURN QUERY SELECT 1, 'Contrato no vigente';
        RETURN;
    END IF;
    -- Obtener datos de unidades y costos
    SELECT cantidad_recolec, EXTRACT(YEAR FROM p_aso_mes_oblig), EXTRACT(MONTH FROM p_aso_mes_oblig), id_rec
      INTO v_unidades, v_ejer, v_mes, v_rec
      FROM ta_16_contratos WHERE control_contrato = p_control_contrato;
    v_ejer_sig := v_ejer + 1;
    -- Costo unidad actual
    SELECT costo_unidad INTO v_costo_unidad FROM ta_16_unidades WHERE ejercicio_recolec = v_ejer AND ctrol_recolec = p_ctrol_recolec LIMIT 1;
    -- Costo unidad siguiente
    SELECT costo_unidad INTO v_costo_unidad_sig FROM ta_16_unidades WHERE ejercicio_recolec = v_ejer_sig AND ctrol_recolec = p_ctrol_recolec LIMIT 1;
    v_importe := v_unidades * COALESCE(v_costo_unidad,0);
    v_importe_sig := v_unidades * COALESCE(v_costo_unidad_sig,0);
    -- Eliminar pagos anteriores al periodo
    DELETE FROM ta_16_pagos WHERE control_contrato = p_control_contrato AND aso_mes_pago < p_aso_mes_oblig;
    -- Insertar pagos del año actual
    FOR i IN v_mes..12 LOOP
        IF NOT EXISTS (
            SELECT 1 FROM ta_16_pagos WHERE control_contrato = p_control_contrato AND aso_mes_pago = make_date(v_ejer, i, 1) AND ctrol_operacion = 6
        ) THEN
            INSERT INTO ta_16_pagos (control_contrato, aso_mes_pago, ctrol_operacion, importe, status_vigencia, usuario, exedencias)
            VALUES (p_control_contrato, make_date(v_ejer, i, 1), 6, v_importe, 'V', v_usuario, v_unidades);
        END IF;
    END LOOP;
    -- Insertar pagos del año siguiente si existe tarifa
    IF v_costo_unidad_sig IS NOT NULL THEN
        FOR j IN 1..12 LOOP
            IF NOT EXISTS (
                SELECT 1 FROM ta_16_pagos WHERE control_contrato = p_control_contrato AND aso_mes_pago = make_date(v_ejer_sig, j, 1) AND ctrol_operacion = 6
            ) THEN
                INSERT INTO ta_16_pagos (control_contrato, aso_mes_pago, ctrol_operacion, importe, status_vigencia, usuario, exedencias)
                VALUES (p_control_contrato, make_date(v_ejer_sig, j, 1), 6, v_importe_sig, 'V', v_usuario, v_unidades);
            END IF;
        END LOOP;
    END IF;
    -- Actualizar contrato
    UPDATE ta_16_contratos SET aso_mes_oblig = p_aso_mes_oblig, usuario = v_usuario WHERE control_contrato = p_control_contrato;
    -- Insertar documento probatorio
    INSERT INTO ta_16_contratos_h (control, control_contrato, documento, descripcion, id_usuario, fecha_movto)
    VALUES (0, p_control_contrato, p_docto, p_descrip, v_usuario, now());
    RETURN QUERY SELECT 0, 'Inicio de obligación actualizado correctamente';
END;
$$ LANGUAGE plpgsql;