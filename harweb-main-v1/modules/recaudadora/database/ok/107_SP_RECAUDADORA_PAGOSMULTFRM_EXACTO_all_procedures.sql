-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: PAGOSMULTFRM (EXACTO del archivo original)
-- Archivo: 107_SP_RECAUDADORA_PAGOSMULTFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 1/7: pagosmultfrm_search_pagos_multas
-- Tipo: Report
-- Descripción: Busca pagos de multas según los filtros proporcionados.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_search_pagos_multas(
    p_fecha DATE DEFAULT NULL,
    p_recaud SMALLINT DEFAULT NULL,
    p_caja TEXT DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_nombre TEXT DEFAULT NULL,
    p_num_acta INTEGER DEFAULT NULL
)
RETURNS TABLE (
    cvepago INTEGER,
    cvecuenta INTEGER,
    recaud SMALLINT,
    caja TEXT,
    folio INTEGER,
    fecha DATE,
    hora TIME,
    importe NUMERIC,
    cajero TEXT,
    cvecanc INTEGER,
    cveconcepto INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.cvecuenta, p.recaud, p.caja, p.folio, p.fecha, p.hora, p.importe, p.cajero, p.cvecanc, p.cveconcepto
    FROM pagos p
    WHERE p.cveconcepto = 6
      AND (p_fecha IS NULL OR p.fecha = p_fecha)
      AND (p_recaud IS NULL OR p.recaud = p_recaud)
      AND (p_caja IS NULL OR p.caja = p_caja)
      AND (p_folio IS NULL OR p.folio = p_folio)
      AND (
        p_nombre IS NULL OR p.cvepago IN (
          SELECT m.cvepago FROM multas m WHERE m.contribuyente ILIKE '%' || p_nombre || '%'
        )
      )
      AND (
        p_num_acta IS NULL OR p.cvepago IN (
          SELECT m.cvepago FROM multas m WHERE m.num_acta = p_num_acta
        )
      )
    ORDER BY p.fecha, p.recaud, p.caja, p.folio;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: PAGOSMULTFRM (EXACTO del archivo original)
-- Archivo: 107_SP_RECAUDADORA_PAGOSMULTFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 3/7: pagosmultfrm_get_pagoscan
-- Tipo: Report
-- Descripción: Obtiene los registros de pagos cancelados para un pago específico.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_get_pagoscan(
    p_cvepago INTEGER
)
RETURNS TABLE (
    cvecanc INTEGER,
    cvepago INTEGER,
    autorizo TEXT,
    fechacan DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecanc, cvepago, autorizo, fechacan
    FROM pagoscan
    WHERE cvepago = p_cvepago;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: PAGOSMULTFRM (EXACTO del archivo original)
-- Archivo: 107_SP_RECAUDADORA_PAGOSMULTFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 5/7: pagosmultfrm_get_ley
-- Tipo: Catalog
-- Descripción: Obtiene la descripción de la ley para una dependencia y ley dada.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_get_ley(
    p_id_dependencia SMALLINT,
    p_id_ley SMALLINT
)
RETURNS TABLE (
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT descripcion
    FROM c_leyes
    WHERE id_dependencia = p_id_dependencia AND id_ley = p_id_ley;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - RECAUDADORA
-- Formulario: PAGOSMULTFRM (EXACTO del archivo original)
-- Archivo: 107_SP_RECAUDADORA_PAGOSMULTFRM_EXACTO_all_procedures.sql
-- Generado: 2025-09-10
-- Total SPs: 7 (EXACTO)
-- ============================================

-- SP 7/7: pagosmultfrm_get_dependencia
-- Tipo: Catalog
-- Descripción: Obtiene la descripción de la dependencia.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION pagosmultfrm_get_dependencia(
    p_id_dependencia SMALLINT
)
RETURNS TABLE (
    descripcion TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT descripcion
    FROM c_dependencias
    WHERE id_dependencia = p_id_dependencia;
END;
$$ LANGUAGE plpgsql;

-- ============================================

