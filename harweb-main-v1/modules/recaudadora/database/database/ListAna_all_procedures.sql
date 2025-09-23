-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: ListAna
-- Generado: 2025-08-27 12:52:10
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_get_cajas_by_fecha_recaud
-- Tipo: Catalog
-- Descripción: Obtiene las cajas disponibles para una fecha y recaudadora específica.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_cajas_by_fecha_recaud(p_fecha DATE, p_recaud SMALLINT)
RETURNS TABLE(caja VARCHAR) AS $$
BEGIN
  RETURN QUERY
    SELECT DISTINCT caja FROM pagos WHERE fecha = p_fecha AND recaud = p_recaud;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_get_tot_imp
-- Tipo: Report
-- Descripción: Obtiene el total de importes para una caja, recaudadora y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_tot_imp(p_fecha DATE, p_caja VARCHAR, p_recaud SMALLINT)
RETURNS TABLE(tot_imp NUMERIC) AS $$
BEGIN
  RETURN QUERY
    SELECT COALESCE(SUM(importe),0) AS tot_imp FROM pagos WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_get_min_folio
-- Tipo: Report
-- Descripción: Obtiene el folio mínimo para una caja, recaudadora y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_min_folio(p_fecha DATE, p_caja VARCHAR, p_recaud SMALLINT)
RETURNS TABLE(minimo INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT MIN(folio) AS minimo FROM pagos WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_get_max_folio
-- Tipo: Report
-- Descripción: Obtiene el folio máximo para una caja, recaudadora y fecha.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_max_folio(p_fecha DATE, p_caja VARCHAR, p_recaud SMALLINT)
RETURNS TABLE(maximo INTEGER) AS $$
BEGIN
  RETURN QUERY
    SELECT MAX(folio) AS maximo FROM pagos WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_get_pagos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de pagos para una caja, recaudadora y fecha, incluyendo datos de convcta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_get_pagos_detalle(p_fecha DATE, p_caja VARCHAR, p_recaud SMALLINT)
RETURNS TABLE(
  folio INTEGER,
  recaud SMALLINT,
  cvemunicipio VARCHAR,
  cuenta VARCHAR,
  importe NUMERIC,
  reca VARCHAR
) AS $$
BEGIN
  RETURN QUERY
    SELECT p.folio, p.recaud, c.cvemunicipio, c.cuenta, p.importe, c.recaud AS reca
    FROM pagos p
    LEFT JOIN convcta c ON p.cvecuenta = c.cvecuenta
    WHERE p.caja = p_caja AND p.recaud = p_recaud AND p.fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;

-- ============================================

