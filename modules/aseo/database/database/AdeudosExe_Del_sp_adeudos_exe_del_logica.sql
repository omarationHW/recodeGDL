-- Stored Procedure: sp_adeudos_exe_del_logica
-- Tipo: CRUD
-- Descripción: Realiza baja lógica (UPDATE status_vigencia = 'B') del registro de pago de un contrato para un periodo y operación específica.
-- Generado para formulario: AdeudosExe_Del
-- Fecha: 2025-08-27 13:37:22

CREATE OR REPLACE PROCEDURE sp_adeudos_exe_del_logica(
    p_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER,
    p_oficio TEXT,
    p_usuario_id INTEGER,
    OUT p_updated INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    v_control_contrato INTEGER;
    v_periodo TEXT;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM ta_16_contratos
    WHERE num_contrato = p_contrato AND ctrol_aseo = p_ctrol_aseo;
    IF v_control_contrato IS NULL THEN
        p_updated := 0;
        RETURN;
    END IF;
    v_periodo := lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0');
    UPDATE ta_16_pagos
    SET status_vigencia = 'B', usuario = p_usuario_id, folio_rcbo = p_oficio
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago = v_periodo
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';
    GET DIAGNOSTICS p_updated = ROW_COUNT;
END;$$;