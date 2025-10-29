-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_OPCMULT (EXACTO del archivo original)
-- Archivo: 49_SP_ASEO_ADEUDOS_OPCMULT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
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
  FROM public.ta_16_pagos p
  JOIN public.ta_16_operacion o ON o.ctrol_operacion = p.ctrol_operacion
  WHERE p.control_contrato = p_control
    AND p.status_vigencia = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_OPCMULT (EXACTO del archivo original)
-- Archivo: 49_SP_ASEO_ADEUDOS_OPCMULT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

-- SP 3/4: vw_contratos_detalle
-- Tipo: Catalog
-- Descripción: Vista para obtener detalle de contrato por número y tipo de aseo
-- --------------------------------------------

CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT
  c.*, e.descripcion as nom_emp, e.representante, e.domicilio, c.status_vigencia
FROM public.ta_16_contratos c
JOIN public.ta_16_empresas e ON e.num_empresa = c.num_empresa AND e.ctrol_emp = c.ctrol_emp;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - ASEO
-- Formulario: ADEUDOS_OPCMULT (EXACTO del archivo original)
-- Archivo: 49_SP_ASEO_ADEUDOS_OPCMULT_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 4 (EXACTO)
-- ============================================

