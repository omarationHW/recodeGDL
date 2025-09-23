-- Stored Procedure: buscar_recibo_pago
-- Tipo: Report
-- Descripción: Busca un recibo de pago por recaudadora, caja, folio, importe y fecha (opcional). Devuelve los datos del recibo y sus relaciones.
-- Generado para formulario: cancelarecibo
-- Fecha: 2025-08-26 23:05:38

CREATE OR REPLACE FUNCTION buscar_recibo_pago(
    p_recaud INTEGER,
    p_caja TEXT,
    p_folio INTEGER,
    p_importe NUMERIC,
    p_fecha DATE,
    p_user_name TEXT
) RETURNS TABLE(
    cvepago INTEGER,
    cvecuenta INTEGER,
    fecha DATE,
    hora TIME,
    importe NUMERIC,
    cvecanc INTEGER,
    gaspag NUMERIC,
    mulpag NUMERIC,
    cveconcepto INTEGER,
    impuesto NUMERIC,
    recargos NUMERIC
) AS $$
BEGIN
    IF p_user_name = 'proceso' AND p_fecha IS NOT NULL THEN
        RETURN QUERY
        SELECT p.cvepago, p.cvecuenta, p.fecha, p.hora, p.importe, p.cvecanc,
               g.gaspag, g.mulpag, p.cveconcepto, tp.impuesto, tp.recargos
        FROM pagos p
        LEFT JOIN gastmult g ON g.cvepago = p.cvepago
        LEFT JOIN imprectp tp ON tp.cvepago = p.cvepago
        WHERE p.recaud = p_recaud
          AND p.caja = p_caja
          AND p.folio = p_folio
          AND p.fecha = p_fecha
          AND p.importe = p_importe;
    ELSE
        RETURN QUERY
        SELECT p.cvepago, p.cvecuenta, p.fecha, p.hora, p.importe, p.cvecanc,
               g.gaspag, g.mulpag, p.cveconcepto, tp.impuesto, tp.recargos
        FROM pagos p
        LEFT JOIN gastmult g ON g.cvepago = p.cvepago
        LEFT JOIN imprectp tp ON tp.cvepago = p.cvepago
        WHERE p.recaud = p_recaud
          AND p.caja = p_caja
          AND p.folio = p_folio
          AND p.fecha = CURRENT_DATE
          AND p.importe = p_importe;
    END IF;
END;
$$ LANGUAGE plpgsql;