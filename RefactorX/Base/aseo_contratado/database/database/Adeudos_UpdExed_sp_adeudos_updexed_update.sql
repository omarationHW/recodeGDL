-- Stored Procedure: sp_adeudos_updexed_update
-- Tipo: CRUD
-- Descripción: Actualiza la cantidad de excedencias y el importe para un registro vigente.
-- Generado para formulario: Adeudos_UpdExed
-- Fecha: 2025-08-27 13:55:12

CREATE OR REPLACE FUNCTION sp_adeudos_updexed_update(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_ejercicio INTEGER,
    p_mes INTEGER,
    p_ctrol_operacion INTEGER,
    p_cantidad INTEGER,
    p_oficio VARCHAR,
    p_usuario INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_control_contrato INTEGER;
    v_costo_exed NUMERIC;
    v_periodo VARCHAR;
    v_affected INTEGER;
BEGIN
    SELECT a.control_contrato, c.costo_exed
    INTO v_control_contrato, v_costo_exed
    FROM ta_16_contratos a
    JOIN ta_16_unidades b ON b.ctrol_recolec = a.ctrol_recolec
    JOIN ta_16_unidades c ON c.cve_recolec = b.cve_recolec AND c.ejercicio_recolec = p_ejercicio
    WHERE a.num_contrato = p_num_contrato AND a.ctrol_aseo = p_ctrol_aseo
    LIMIT 1;
    IF v_control_contrato IS NULL THEN
        RAISE EXCEPTION 'Contrato no encontrado';
    END IF;
    v_periodo := lpad(p_ejercicio::text,4,'0')||'-'||lpad(p_mes::text,2,'0');
    UPDATE ta_16_pagos
    SET importe = p_cantidad * v_costo_exed,
        folio_rcbo = p_oficio,
        usuario = p_usuario,
        exedencias = p_cantidad
    WHERE control_contrato = v_control_contrato
      AND aso_mes_pago = v_periodo
      AND ctrol_operacion = p_ctrol_operacion
      AND status_vigencia = 'V';
    GET DIAGNOSTICS v_affected = ROW_COUNT;
    RETURN v_affected;
END;
$$ LANGUAGE plpgsql;