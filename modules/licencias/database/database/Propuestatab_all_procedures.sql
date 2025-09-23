-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: Propuestatab
-- Generado: 2025-08-27 18:59:08
-- Total SPs: 5
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

-- SP 2/5: propuestatab_regimen
-- Tipo: Catalog
-- Descripción: Obtiene el régimen de propiedad de la cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION propuestatab_regimen(p_cvecuenta INTEGER)
RETURNS TABLE(
  cvereg INTEGER,
  encabeza VARCHAR,
  porcentaje NUMERIC,
  descripcion VARCHAR,
  exento VARCHAR,
  ncompleto VARCHAR,
  rfc VARCHAR,
  calle VARCHAR,
  noexterior VARCHAR,
  interior VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT r.cvereg, r.encabeza, r.porcentaje, r.descripcion, r.exento,
         r.ncompleto, r.rfc, r.calle, r.noexterior, r.interior
  FROM regimen_propiedad r
  WHERE r.cvecuenta = p_cvecuenta;
END;
$$ LANGUAGE plpgsql;

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

-- SP 4/5: propuestatab_obs400
-- Tipo: Catalog
-- Descripción: Obtiene observaciones AS-400 para la cuenta
-- --------------------------------------------

CREATE OR REPLACE FUNCTION propuestatab_obs400(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
RETURNS TABLE(
  acomp INTEGER,
  observa VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT o.acomp, o.observa
  FROM observ_400 o
  WHERE o.recaud = p_recaud AND o.urbrus = p_urbrus AND o.cuenta = p_cuenta;
END;
$$ LANGUAGE plpgsql;

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

