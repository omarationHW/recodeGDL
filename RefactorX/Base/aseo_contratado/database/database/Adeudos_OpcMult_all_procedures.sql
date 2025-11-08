-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Adeudos_OpcMult
-- Generado: 2025-08-27 20:39:32
-- Total SPs: 4
-- ============================================

-- SP 1/4: con16_detade_021
-- Tipo: Report
-- Descripción: Devuelve los adeudos pendientes de un contrato para la opción múltiple
-- --------------------------------------------

CREATE OR REPLACE FUNCTION con16_detade_021(p_control integer)
RETURNS TABLE (
  expression integer,
  expression_1 varchar,
  expression_2 varchar,
  expression_3 integer,
  expression_4 integer,
  expression_5 numeric,
  expression_6 numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.control_contrato,
    to_char(p.aso_mes_pago, 'YYYY-MM'),
    o.descripcion,
    p.ctrol_operacion,
    p.exedencias,
    p.importe,
    0.0
  FROM ta_16_pagos p
  JOIN ta_16_operacion o ON o.ctrol_operacion = p.ctrol_operacion
  WHERE p.control_contrato = p_control
    AND p.status_vigencia = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/4: upd16_ade
-- Tipo: CRUD
-- Descripción: Actualiza el estado de adeudo (pagado, condonado, cancelado, prescrito) para un periodo de un contrato
-- --------------------------------------------

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

-- ============================================

-- SP 3/4: vw_contratos_detalle
-- Tipo: Catalog
-- Descripción: Vista para obtener detalle de contrato por número y tipo de aseo
-- --------------------------------------------

CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT
  c.*, e.descripcion as nom_emp, e.representante, e.domicilio, c.status_vigencia
FROM ta_16_contratos c
JOIN ta_16_empresas e ON e.num_empresa = c.num_empresa AND e.ctrol_emp = c.ctrol_emp;

-- ============================================

-- SP 4/4: vw_convenios
-- Tipo: Catalog
-- Descripción: Vista para obtener convenio de un contrato
-- --------------------------------------------

CREATE OR REPLACE VIEW vw_convenios AS
SELECT a.id_referencia as idlc, (trim(d.letras_exp)||'/'||d.numero_exp||'/'||d.axo_exp) as convenio
FROM ta_17_referencia a
JOIN ta_17_conv_d_resto b ON b.id_conv_resto = a.id_conv_resto AND b.vigencia = 'A'
JOIN ta_17_conv_diverso d ON d.tipo = b.tipo AND d.id_conv_diver = b.id_conv_diver;

-- ============================================

