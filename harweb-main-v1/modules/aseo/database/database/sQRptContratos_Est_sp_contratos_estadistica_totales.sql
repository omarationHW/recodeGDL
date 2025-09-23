-- Stored Procedure: sp_contratos_estadistica_totales
-- Tipo: Report
-- Descripción: Devuelve los totales generales de contratos de todos los tipos de aseo
-- Generado para formulario: sQRptContratos_Est
-- Fecha: 2025-08-27 15:30:18

CREATE OR REPLACE FUNCTION sp_contratos_estadistica_totales()
RETURNS TABLE(
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
BEGIN
  RETURN QUERY
  SELECT
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
  JOIN ta_16_operacion o ON p.ctrol_operacion = o.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;