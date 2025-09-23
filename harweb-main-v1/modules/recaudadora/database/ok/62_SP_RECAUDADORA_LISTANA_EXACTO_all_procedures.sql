-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LISTANA (EXACTO del archivo original)
-- Archivo: 62_SP_RECAUDADORA_LISTANA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LISTANA (EXACTO del archivo original)
-- Archivo: 62_SP_RECAUDADORA_LISTANA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: LISTANA (EXACTO del archivo original)
-- Archivo: 62_SP_RECAUDADORA_LISTANA_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 5 (EXACTO)
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

