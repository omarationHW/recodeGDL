-- Stored Procedure: sp_contratos_estadistica_periodo
-- Tipo: Report
-- Descripción: Devuelve la estadística de contratos por tipo de aseo y periodo (año/mes inicio y fin)
-- Generado para formulario: sQRptContratos_Est
-- Fecha: 2025-08-27 15:30:18

CREATE OR REPLACE FUNCTION sp_contratos_estadistica_periodo(
  p_cve_aseo TEXT,
  p_aso_in INT,
  p_mes_in INT,
  p_aso_fin INT,
  p_mes_fin INT
) RETURNS TABLE(
  tipo_aseo TEXT,
  total_contratos INTEGER,
  importe_total NUMERIC,
  cuota_normal INTEGER,
  excedentes INTEGER,
  contenedores INTEGER,
  vigentes INTEGER,
  cancelados INTEGER,
  pagados INTEGER,
  condonados INTEGER
) AS $$
DECLARE
  fecha_ini DATE := make_date(p_aso_in, p_mes_in, 1);
  fecha_fin DATE := make_date(p_aso_fin, p_mes_fin, 1);
BEGIN
  RETURN QUERY
  SELECT
    c.tipo_aseo,
    COUNT(DISTINCT c.control_contrato) AS total_contratos,
    SUM(p.importe) AS importe_total,
    SUM(CASE WHEN o.cve_operacion = 'C' THEN 1 ELSE 0 END) AS cuota_normal,
    SUM(CASE WHEN o.cve_operacion = 'E' THEN 1 ELSE 0 END) AS excedentes,
    SUM(CASE WHEN o.cve_operacion = 'D' THEN 1 ELSE 0 END) AS contenedores,
    SUM(CASE WHEN p.status_vigencia = 'V' THEN 1 ELSE 0 END) AS vigentes,
    SUM(CASE WHEN p.status_vigencia = 'C' THEN 1 ELSE 0 END) AS cancelados,
    SUM(CASE WHEN p.status_vigencia = 'P' THEN 1 ELSE 0 END) AS pagados,
    SUM(CASE WHEN p.status_vigencia = 'S' THEN 1 ELSE 0 END) AS condonados
  FROM ta_16_contratos c
  JOIN ta_16_pagos p ON c.control_contrato = p.control_contrato
  JOIN ta_16_operacion o ON p.ctrol_operacion = o.ctrol_operacion
  WHERE (p_cve_aseo = 'T' OR c.tipo_aseo = p_cve_aseo)
    AND p.aso_mes_pago >= fecha_ini
    AND p.aso_mes_pago <= fecha_fin
  GROUP BY c.tipo_aseo;
END;
$$ LANGUAGE plpgsql;