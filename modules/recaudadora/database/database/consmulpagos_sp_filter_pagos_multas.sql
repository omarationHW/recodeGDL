-- Stored Procedure: sp_filter_pagos_multas
-- Tipo: Report
-- Descripción: Filtra pagos de multas por fecha, recaudadora, caja, folio, nombre, num_acta.
-- Generado para formulario: consmulpagos
-- Fecha: 2025-08-26 23:30:27

CREATE OR REPLACE FUNCTION sp_filter_pagos_multas(
    p_fecha date DEFAULT NULL,
    p_recaud integer DEFAULT NULL,
    p_caja varchar DEFAULT NULL,
    p_folio integer DEFAULT NULL,
    p_nombre varchar DEFAULT NULL,
    p_num_acta integer DEFAULT NULL
)
RETURNS TABLE(
    cvepago integer,
    fecha date,
    recaud integer,
    caja varchar,
    folio integer,
    importe numeric,
    cajero varchar,
    contribuyente varchar,
    domicilio varchar,
    num_acta integer,
    axo_acta integer,
    id_dependencia integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.fecha, p.recaud, p.caja, p.folio, p.importe, p.cajero, m.contribuyente, m.domicilio, m.num_acta, m.axo_acta, m.id_dependencia
    FROM pagos p
    INNER JOIN multas m ON p.cvepago = m.cvepago
    WHERE p.cveconcepto = 6
      AND (p_fecha IS NULL OR p.fecha = p_fecha)
      AND (p_recaud IS NULL OR p.recaud = p_recaud)
      AND (p_caja IS NULL OR p.caja = p_caja)
      AND (p_folio IS NULL OR p.folio = p_folio)
      AND (p_nombre IS NULL OR m.contribuyente ILIKE '%' || p_nombre || '%')
      AND (p_num_acta IS NULL OR m.num_acta = p_num_acta)
    ORDER BY p.fecha DESC, p.recaud, p.caja, p.folio;
END;
$$ LANGUAGE plpgsql;