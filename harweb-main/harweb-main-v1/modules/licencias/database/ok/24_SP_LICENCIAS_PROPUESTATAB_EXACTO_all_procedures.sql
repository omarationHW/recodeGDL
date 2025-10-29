-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PROPUESTATAB (EXACTO del archivo original)
-- Archivo: 24_SP_LICENCIAS_PROPUESTATAB_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 1/5: propuestatab_list
-- Tipo: CRUD
-- Descripción: Obtiene los datos principales de la cuenta histórica
-- --------------------------------------------

CREATE OR REPLACE FUNCTION propuestatab_list(p_cvecuenta INTEGER)
RETURNS TABLE(
  cvecuenta INTEGER,
  cvecatnva VARCHAR,
  subpredio INTEGER,
  cmovto VARCHAR,
  observacion TEXT,
  tasa NUMERIC,
  indiviso NUMERIC,
  calle VARCHAR,
  noexterior VARCHAR,
  interior VARCHAR,
  colonia VARCHAR,
  vigencia VARCHAR,
  obsinter TEXT,
  fechaotorg DATE,
  importe NUMERIC,
  valortransm NUMERIC,
  areatitulo NUMERIC,
  notario VARCHAR,
  noescrituras INTEGER,
  recaud INTEGER,
  urbrus VARCHAR,
  cuenta INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.cvecuenta, c.cvecatnva, c.subpredio, c.cmovto, c.observacion, v.tasa, c.indiviso,
         u.calle, u.noexterior, u.interior, u.colonia, u.vigencia, u.obsinter,
         a.fechaotorg, p.importe, p.valortransm, h.areatitulo, n.notario, p.noescrituras,
         c.recaud, c.urbrus, c.cuenta
  FROM cuentas c
  LEFT JOIN valores v ON v.cvecuenta = c.cvecuenta
  LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
  LEFT JOIN pagos p ON p.cvecuenta = c.cvecuenta
  LEFT JOIN historico h ON h.cvecuenta = c.cvecuenta
  LEFT JOIN notarios n ON n.idnotaria = p.idnotaria
  WHERE c.cvecuenta = p_cvecuenta
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PROPUESTATAB (EXACTO del archivo original)
-- Archivo: 24_SP_LICENCIAS_PROPUESTATAB_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 3/5: propuestatab_diferencias
-- Tipo: Report
-- Descripción: Obtiene las diferencias de valores históricos de la cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION propuestatab_diferencias(p_cvecuenta INTEGER)
RETURNS TABLE(
  id SERIAL,
  bimini INTEGER,
  axoini INTEGER,
  bimfin INTEGER,
  axofin INTEGER,
  tasaant NUMERIC,
  stasaant NUMERIC,
  valfisant NUMERIC,
  tasa NUMERIC,
  axosobretasa NUMERIC,
  valfiscal NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT d.id, d.bimini, d.axoini, d.bimfin, d.axofin, d.tasaant, d.stasaant, d.valfisant, d.tasa, d.axosobretasa, d.valfiscal
  FROM diferencias d
  WHERE d.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - LICENCIAS
-- Formulario: PROPUESTATAB (EXACTO del archivo original)
-- Archivo: 24_SP_LICENCIAS_PROPUESTATAB_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
-- ============================================

-- SP 5/5: propuestatab_condominio
-- Tipo: Catalog
-- Descripción: Obtiene información de condominio para la cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION propuestatab_condominio(p_cvecatnva VARCHAR)
RETURNS TABLE(
  nombre VARCHAR,
  tipocond VARCHAR,
  numpred INTEGER,
  escritura INTEGER,
  fecescrit DATE,
  areacomun NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.nombre, c.tipocond, c.numpred, c.escritura, c.fecescrit, c.areacomun
  FROM condominio c
  WHERE c.cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;

-- ============================================

