-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LISTADOMULTIPLE (EXACTO del archivo original)
-- Archivo: 64_SP_RECAUDADORA_LISTADOMULTIPLE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 1/3: conveniosempresas
-- Tipo: Report
-- Descripción: Obtiene convenios de empresas por año y fecha
-- --------------------------------------------

CREATE OR REPLACE FUNCTION conveniosempresas(paxo integer, pfecha date)
RETURNS TABLE(
  cvecuenta integer,
  cuenta varchar,
  folioreq integer,
  req_emision date,
  req_vig varchar,
  despacho varchar,
  conv_inicio date,
  conv_vig varchar,
  req_pagado numeric,
  conv_pagado numeric,
  parcialidad integer,
  importe_parcial numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT cvecuenta, cuenta, folioreq, req_emision, req_vig, despacho, conv_inicio, conv_vig, req_pagado, conv_pagado, parcialidad, importe_parcial
  FROM conveniosempresas_view
  WHERE EXTRACT(YEAR FROM req_emision) = paxo AND req_emision >= pfecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LISTADOMULTIPLE (EXACTO del archivo original)
-- Archivo: 64_SP_RECAUDADORA_LISTADOMULTIPLE_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 3 (EXACTO)
-- ============================================

-- SP 3/3: get_ejecutores_empresas
-- Tipo: Catalog
-- Descripción: Obtiene ejecutores de empresas activos desde una fecha
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_ejecutores_empresas(ftrabajo date)
RETURNS TABLE(
  cveejecutor integer,
  empresa varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT f.cveejecutor, TRIM(e.paterno)||' '||TRIM(e.materno)||' '||TRIM(e.nombres) AS empresa
  FROM ctaempexterna f
  INNER JOIN ejecutor e ON e.cveejecutor=f.cveejecutor
  WHERE f.fecha_trabajo >= ftrabajo;
END;
$$ LANGUAGE plpgsql;

-- ============================================

