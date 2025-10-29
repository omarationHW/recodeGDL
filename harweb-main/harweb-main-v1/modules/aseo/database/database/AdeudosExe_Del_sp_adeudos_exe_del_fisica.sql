-- Stored Procedure: sp_adeudos_exe_del_fisica
-- Tipo: CRUD
-- Descripción: Elimina físicamente (DELETE) el registro de pago de un contrato para un periodo y operación específica.
-- Generado para formulario: AdeudosExe_Del
-- Fecha: 2025-08-27 13:37:22

CREATE OR REPLACE PROCEDURE sp_adeudos_exe_del_fisica(
    p_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER,
    OUT p_deleted INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    v_control_contrato INTEGER;
    v_periodo TEXT;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM ta_16_contratos
    WHERE num_contrato = p_contrato AND ctrol_aseo = p_ctrol_aseo;
    IF v_control_contrato IS NULL THEN
        p_deleted := 0;
        RETURN;
    END IF;
    v_periodo := lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0');
    DELETE FROM ta_16_pagos
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago = v_periodo
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';
    GET DIAGNOSTICS p_deleted = ROW_COUNT;
END;$$;