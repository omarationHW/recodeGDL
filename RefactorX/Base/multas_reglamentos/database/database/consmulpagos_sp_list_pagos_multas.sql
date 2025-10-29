-- Stored Procedure: sp_list_pagos_multas
-- Tipo: Report
-- Descripción: Lista todos los pagos de multas con datos de multa y pago.
-- Generado para formulario: consmulpagos
-- Fecha: 2025-08-26 23:30:27

CREATE OR REPLACE FUNCTION sp_list_pagos_multas()
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
    ORDER BY p.fecha DESC, p.recaud, p.caja, p.folio;
END;
$$ LANGUAGE plpgsql;