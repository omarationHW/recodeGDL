-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ListadoMultiple
-- Generado: 2025-08-27 12:49:10
-- Total SPs: 3
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

-- SP 2/3: pagos_convenios_empresas
-- Tipo: Report
-- Descripción: Obtiene pagos de convenios por empresa y rango de fechas
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagos_convenios_empresas(
  pejec integer,
  pftrab date,
  pfpagod date,
  pfpagoh date
)
RETURNS TABLE(
  cvecuenta integer,
  cuenta varchar,
  foliorecibo varchar,
  fecha_pago date,
  importe_pago numeric,
  convenio varchar,
  fecha_convenio date,
  parc_ini integer,
  parc_fin integer,
  cvereq integer,
  folioreq integer,
  fecha_req date,
  vigencia varchar
) AS $$
BEGIN
  RETURN QUERY
  SELECT cvecuenta, cuenta, foliorecibo, fecha_pago, importe_pago, convenio, fecha_convenio, parc_ini, parc_fin, cvereq, folioreq, fecha_req, vigencia
  FROM pagos_convenios_empresas_view
  WHERE cveejecutor = pejec
    AND fecha_trabajo = pftrab
    AND fecha_pago BETWEEN pfpagod AND pfpagoh;
END;
$$ LANGUAGE plpgsql;

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

