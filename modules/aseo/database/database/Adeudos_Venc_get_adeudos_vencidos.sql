-- Stored Procedure: get_adeudos_vencidos
-- Tipo: Report
-- Descripción: Obtiene los adeudos vencidos de un contrato, filtrando por vigencia y periodo.
-- Generado para formulario: Adeudos_Venc
-- Fecha: 2025-08-27 13:57:03

CREATE OR REPLACE FUNCTION get_adeudos_vencidos(
  p_control_contrato INTEGER,
  p_vigencia VARCHAR DEFAULT 'V',
  p_aso INTEGER DEFAULT NULL,
  p_mes INTEGER DEFAULT NULL
)
RETURNS TABLE (
  cam VARCHAR,
  control_contrato INTEGER,
  aso_mes_pago DATE,
  ctrol_operacion INTEGER,
  descripcion VARCHAR,
  exedencias SMALLINT,
  importe NUMERIC,
  recargos NUMERIC
) AS $$
DECLARE
  v_periodo TEXT;
  v_periodo_fin TEXT;
BEGIN
  IF p_vigencia = 'V' THEN
    RETURN QUERY
    SELECT 'A' AS cam, a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.descripcion, a.exedencias, a.importe,
      (SELECT COALESCE(SUM(porc_recargo),0) FROM ta_16_recargos r WHERE r.aso_mes_recargo BETWEEN to_char(a.aso_mes_pago, 'YYYY-MM') AND to_char(current_date, 'YYYY-MM')) AS recargos
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V'
    ORDER BY a.aso_mes_pago, a.ctrol_operacion;
  ELSE
    v_periodo := p_aso::text || '-' || lpad(p_mes::text,2,'0');
    RETURN QUERY
    SELECT 'A' AS cam, a.control_contrato, a.aso_mes_pago, a.ctrol_operacion, b.descripcion, a.exedencias, a.importe,
      (SELECT COALESCE(SUM(porc_recargo),0) FROM ta_16_recargos r WHERE r.aso_mes_recargo BETWEEN to_char(a.aso_mes_pago, 'YYYY-MM') AND v_periodo) AS recargos
    FROM ta_16_pagos a
    JOIN ta_16_operacion b ON b.ctrol_operacion = a.ctrol_operacion
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V' AND to_char(a.aso_mes_pago, 'YYYY-MM') <= v_periodo
    ORDER BY a.aso_mes_pago, a.ctrol_operacion;
  END IF;
END;
$$ LANGUAGE plpgsql;