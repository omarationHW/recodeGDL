-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_EST (EXACTO del archivo original)
-- Archivo: 108_SP_ASEO_SQRPTCONTRATOS_EST_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: sp_contratos_estadistica
-- Tipo: Report
-- Descripción: Devuelve la estadística general de contratos por tipo de aseo (O, H, C, T)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_contratos_estadistica(p_cve_aseo TEXT)
RETURNS TABLE(
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
BEGIN
  RETURN QUERY
  SELECT
    CASE WHEN p_cve_aseo = 'T' THEN tipo_aseo ELSE p_cve_aseo END AS tipo_aseo,
    COUNT(*) AS total_contratos,
    SUM(importe) AS importe_total,
    SUM(CASE WHEN operacion = 'C' THEN 1 ELSE 0 END) AS cuota_normal,
    SUM(CASE WHEN operacion = 'E' THEN 1 ELSE 0 END) AS excedentes,
    SUM(CASE WHEN operacion = 'D' THEN 1 ELSE 0 END) AS contenedores,
    SUM(CASE WHEN status_vigencia = 'V' THEN 1 ELSE 0 END) AS vigentes,
    SUM(CASE WHEN status_vigencia = 'C' THEN 1 ELSE 0 END) AS cancelados,
    SUM(CASE WHEN status_vigencia = 'P' THEN 1 ELSE 0 END) AS pagados,
    SUM(CASE WHEN status_vigencia = 'S' THEN 1 ELSE 0 END) AS condonados
  FROM (
    SELECT c.tipo_aseo, p.importe, o.cve_operacion AS operacion, p.status_vigencia
    FROM public.ta_16_contratos c
    JOIN public.ta_16_pagos p ON c.control_contrato = p.control_contrato
    JOIN public.ta_16_operacion o ON p.ctrol_operacion = o.ctrol_operacion
    WHERE (p_cve_aseo = 'T' OR c.tipo_aseo = p_cve_aseo)
  ) sub;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: SQRPTCONTRATOS_EST (EXACTO del archivo original)
-- Archivo: 108_SP_ASEO_SQRPTCONTRATOS_EST_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: sp_contratos_estadistica_totales
-- Tipo: Report
-- Descripción: Devuelve los totales generales de contratos de todos los tipos de aseo
-- --------------------------------------------

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
  FROM public.ta_16_contratos c
  JOIN public.ta_16_pagos p ON c.control_contrato = p.control_contrato
  JOIN public.ta_16_operacion o ON p.ctrol_operacion = o.ctrol_operacion;
END;
$$ LANGUAGE plpgsql;

-- ============================================

