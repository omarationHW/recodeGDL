-- Stored Procedure: reporte_adeudos_vencidos
-- Tipo: Report
-- Descripción: Genera un resumen de adeudos vencidos para un contrato (multas, recargos, gastos, total).
-- Generado para formulario: Adeudos_Venc
-- Fecha: 2025-08-27 13:57:03

CREATE OR REPLACE FUNCTION reporte_adeudos_vencidos(
  p_control_contrato INTEGER,
  p_vigencia VARCHAR DEFAULT 'V',
  p_aso INTEGER DEFAULT NULL,
  p_mes INTEGER DEFAULT NULL
)
RETURNS TABLE (
  requerimientos INTEGER,
  importe_multa NUMERIC,
  importe_gastos NUMERIC,
  importe_recargos NUMERIC,
  total_adeudos NUMERIC
) AS $$
DECLARE
  v_periodo TEXT;
  v_total NUMERIC := 0;
  v_multa NUMERIC := 0;
  v_gastos NUMERIC := 0;
  v_recargos NUMERIC := 0;
  v_req INTEGER := 0;
BEGIN
  -- Multas y gastos
  SELECT COALESCE(SUM(importe_multa),0), COALESCE(SUM(importe_gastos),0), COUNT(*)
    INTO v_multa, v_gastos, v_req
  FROM ta_15_apremios
  WHERE modulo = 16 AND control_otr = p_control_contrato AND vigencia = '1' AND clave_practicado = 'P';

  -- Recargos y total adeudos
  IF p_vigencia = 'V' THEN
    SELECT COALESCE(SUM((SELECT COALESCE(SUM(porc_recargo),0) FROM ta_16_recargos r WHERE r.aso_mes_recargo BETWEEN to_char(a.aso_mes_pago, 'YYYY-MM') AND to_char(current_date, 'YYYY-MM'))),0),
           COALESCE(SUM(a.importe),0)
      INTO v_recargos, v_total
    FROM ta_16_pagos a
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V';
  ELSE
    v_periodo := p_aso::text || '-' || lpad(p_mes::text,2,'0');
    SELECT COALESCE(SUM((SELECT COALESCE(SUM(porc_recargo),0) FROM ta_16_recargos r WHERE r.aso_mes_recargo BETWEEN to_char(a.aso_mes_pago, 'YYYY-MM') AND v_periodo)),0),
           COALESCE(SUM(a.importe),0)
      INTO v_recargos, v_total
    FROM ta_16_pagos a
    WHERE a.control_contrato = p_control_contrato AND a.status_vigencia = 'V' AND to_char(a.aso_mes_pago, 'YYYY-MM') <= v_periodo;
  END IF;

  RETURN QUERY SELECT v_req, v_multa, v_gastos, v_recargos, v_total + v_multa + v_gastos + v_recargos;
END;
$$ LANGUAGE plpgsql;