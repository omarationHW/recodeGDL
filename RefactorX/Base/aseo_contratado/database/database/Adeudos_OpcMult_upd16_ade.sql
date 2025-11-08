-- Stored Procedure: upd16_ade
-- Tipo: CRUD
-- Descripción: Actualiza el estado de adeudo (pagado, condonado, cancelado, prescrito) para un periodo de un contrato
-- Generado para formulario: Adeudos_OpcMult
-- Fecha: 2025-08-27 20:39:32

CREATE OR REPLACE FUNCTION upd16_ade(
  p_control_contrato integer,
  p_periodo varchar,
  p_ctrol_oper integer,
  p_vigencia char(1),
  p_fecha date,
  p_reca integer,
  p_caja varchar,
  p_operacion integer,
  p_folio_rcbo varchar,
  p_obs varchar
) RETURNS text AS $$
DECLARE
  v_count integer;
BEGIN
  -- Validar existencia
  SELECT count(*) INTO v_count FROM ta_16_pagos
    WHERE control_contrato = p_control_contrato
      AND to_char(aso_mes_pago, 'YYYY-MM') = p_periodo
      AND ctrol_operacion = p_ctrol_oper
      AND status_vigencia = 'V';
  IF v_count = 0 THEN
    RETURN 'No existe adeudo vigente para el periodo';
  END IF;
  -- Actualizar
  UPDATE ta_16_pagos
    SET status_vigencia = p_vigencia,
        fecha_hora_pago = p_fecha,
        id_rec = p_reca,
        caja = p_caja,
        consec_operacion = CASE WHEN p_vigencia = 'P' THEN p_operacion ELSE 0 END,
        folio_rcbo = p_folio_rcbo,
        observaciones = p_obs
    WHERE control_contrato = p_control_contrato
      AND to_char(aso_mes_pago, 'YYYY-MM') = p_periodo
      AND ctrol_operacion = p_ctrol_oper
      AND status_vigencia = 'V';
  RETURN 'OK';
END;
$$ LANGUAGE plpgsql;