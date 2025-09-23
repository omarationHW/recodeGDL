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

CREATE OR REPLACE PROCEDURE sp_pagar_apremio(
    p_fecha DATE,
    p_id_rec INTEGER,
    p_caja VARCHAR,
    p_operacion INTEGER,
    p_importe_gastos NUMERIC,
    p_id_control INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE ta_15_apremios
    SET fecha_pago = p_fecha,
        recaudadora = p_id_rec,
        caja = p_caja,
        operacion = p_operacion,
        vigencia = '2',
        clave_mov = 'P',
        importe_pago = p_importe_gastos
    WHERE id_control = p_id_control;
END;
$$;

CREATE OR REPLACE FUNCTION sp_buscar_contrato(p_num_contrato INTEGER, p_ctrol_aseo INTEGER)
RETURNS TABLE(control_contrato INTEGER, status_vigencia VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT control_contrato, status_vigencia FROM ta_16_contratos WHERE num_contrato = p_num_contrato AND ctrol_aseo = p_ctrol_aseo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscar_apremios(p_control_contrato INTEGER)
RETURNS TABLE(id_control INTEGER, folio INTEGER, importe_multa NUMERIC, importe_recargo NUMERIC, importe_gastos NUMERIC, fecha_emision DATE, fecha_practicado DATE, vigencia VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT id_control, folio, importe_multa, importe_recargo, importe_gastos, fecha_emision, fecha_practicado, vigencia FROM ta_15_apremios WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P' ORDER BY folio;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscar_periodos_apremio(p_id_apremio INTEGER)
RETURNS TABLE(id_control INTEGER, control_otr INTEGER, ayo SMALLINT, periodo SMALLINT, importe NUMERIC, recargos NUMERIC, cantidad NUMERIC, tipo INTEGER) AS $$
BEGIN
    RETURN QUERY SELECT id_control, control_otr, ayo, periodo, importe, recargos, cantidad, tipo FROM ta_15_periodos WHERE control_otr = p_id_apremio ORDER BY ayo, periodo;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_buscar_convenio(p_idlc INTEGER)
RETURNS TABLE(convenio VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) convenio FROM ta_17_referencia a, ta_17_conv_d_resto b, ta_17_conv_diverso d WHERE a.id_referencia = p_idlc AND a.modulo = 16 AND b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A' AND d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;
END;
$$ LANGUAGE plpgsql;