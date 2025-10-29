-- Stored Procedure: sp_detail_pago_multa
-- Tipo: Report
-- Descripción: Devuelve el detalle completo de un pago de multa.
-- Generado para formulario: consmulpagos
-- Fecha: 2025-08-26 23:30:27

CREATE OR REPLACE FUNCTION sp_detail_pago_multa(p_cvepago integer)
RETURNS TABLE(
    cvepago integer,
    fecha date,
    recaud integer,
    caja varchar,
    folio integer,
    importe numeric,
    cajero varchar,
    cveconcepto integer,
    contribuyente varchar,
    domicilio varchar,
    num_acta integer,
    axo_acta integer,
    id_dependencia integer,
    multa numeric,
    calificacion numeric,
    total numeric,
    observacion text
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.cvepago, p.fecha, p.recaud, p.caja, p.folio, p.importe, p.cajero, p.cveconcepto, m.contribuyente, m.domicilio, m.num_acta, m.axo_acta, m.id_dependencia, m.multa, m.calificacion, m.total, m.observacion
    FROM pagos p
    INNER JOIN multas m ON p.cvepago = m.cvepago
    WHERE p.cvepago = p_cvepago;
END;
$$ LANGUAGE plpgsql;