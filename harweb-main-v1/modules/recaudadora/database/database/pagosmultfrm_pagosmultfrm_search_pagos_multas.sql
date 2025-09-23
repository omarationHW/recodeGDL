-- Stored Procedure: pagosmultfrm_search_pagos_multas
-- Tipo: Report
-- Descripción: Busca pagos de multas según los filtros proporcionados.
-- Generado para formulario: pagosmultfrm
-- Fecha: 2025-08-27 14:09:11

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