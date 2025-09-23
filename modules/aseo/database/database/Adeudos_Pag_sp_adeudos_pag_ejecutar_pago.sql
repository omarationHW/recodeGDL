-- Stored Procedure: sp_adeudos_pag_ejecutar_pago
-- Tipo: CRUD
-- Descripción: Marca como pagado los adeudos seleccionados (cuota normal y/o excedencias) para un contrato y periodo.
-- Generado para formulario: Adeudos_Pag
-- Fecha: 2025-08-27 13:49:54

-- PostgreSQL
CREATE OR REPLACE FUNCTION sp_adeudos_pag_ejecutar_pago(
    p_num_contrato INTEGER,
    p_ctrol_aseo INTEGER,
    p_aso INTEGER,
    p_mes INTEGER,
    p_consec_oper INTEGER,
    p_folio_rcbo TEXT,
    p_fecha_pagado DATE,
    p_id_rec INTEGER,
    p_caja TEXT,
    p_usuario_id INTEGER,
    p_pagar_cn BOOLEAN,
    p_importe_cn NUMERIC,
    p_pagar_exe BOOLEAN,
    p_importe_exe NUMERIC
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_control_contrato INTEGER;
    v_ctrol_oper_cn INTEGER;
    v_ctrol_oper_exe INTEGER;
    v_rows INTEGER;
BEGIN
    SELECT control_contrato INTO v_control_contrato
    FROM ta_16_contratos
    WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No existe contrato con los datos proporcionados.';
        RETURN;
    END IF;
    SELECT ctrol_operacion INTO v_ctrol_oper_cn FROM ta_16_operacion WHERE cve_operacion = 'C' LIMIT 1;
    SELECT ctrol_operacion INTO v_ctrol_oper_exe FROM ta_16_operacion WHERE cve_operacion = 'E' LIMIT 1;
    IF p_pagar_cn THEN
        UPDATE ta_16_pagos SET
            importe = p_importe_cn,
            status_vigencia = 'P',
            fecha_hora_pago = p_fecha_pagado,
            id_rec = p_id_rec,
            caja = p_caja,
            consec_operacion = p_consec_oper,
            folio_rcbo = p_folio_rcbo,
            usuario = p_usuario_id
        WHERE control_contrato = v_control_contrato
          AND to_char(aso_mes_pago, 'YYYY-MM') = lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0')
          AND ctrol_operacion = v_ctrol_oper_cn
          AND status_vigencia = 'V';
        GET DIAGNOSTICS v_rows = ROW_COUNT;
        IF v_rows = 0 THEN
            RETURN QUERY SELECT FALSE, 'No se encontró adeudo de cuota normal vigente para pagar.';
            RETURN;
        END IF;
    END IF;
    IF p_pagar_exe THEN
        UPDATE ta_16_pagos SET
            importe = p_importe_exe,
            status_vigencia = 'P',
            fecha_hora_pago = p_fecha_pagado,
            id_rec = p_id_rec,
            caja = p_caja,
            consec_operacion = p_consec_oper,
            folio_rcbo = p_folio_rcbo,
            usuario = p_usuario_id
        WHERE control_contrato = v_control_contrato
          AND to_char(aso_mes_pago, 'YYYY-MM') = lpad(p_aso::text,4,'0') || '-' || lpad(p_mes::text,2,'0')
          AND ctrol_operacion = v_ctrol_oper_exe
          AND status_vigencia = 'V';
        GET DIAGNOSTICS v_rows = ROW_COUNT;
        IF v_rows = 0 THEN
            RETURN QUERY SELECT FALSE, 'No se encontró adeudo de excedencias vigente para pagar.';
            RETURN;
        END IF;
    END IF;
    RETURN QUERY SELECT TRUE, 'Pago realizado correctamente.';
END;
$$ LANGUAGE plpgsql;