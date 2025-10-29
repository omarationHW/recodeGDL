-- Stored Procedure: repoper_desglose
-- Tipo: Report
-- Descripción: Devuelve el desglose de operaciones por caja, recaudadora y fecha.
-- Generado para formulario: RepOper
-- Fecha: 2025-08-27 14:28:37

CREATE OR REPLACE FUNCTION repoper_desglose(p_fecha DATE, p_recaud INTEGER, p_caja TEXT)
RETURNS TABLE(
  cvepago INTEGER,
  cvecuenta INTEGER,
  recaud SMALLINT,
  caja TEXT,
  folio INTEGER,
  fecha DATE,
  hora TIMESTAMP,
  importe NUMERIC,
  cajero TEXT,
  cvecanc INTEGER,
  cveconcepto INTEGER,
  mensaje TEXT,
  cvectaapl INTEGER,
  recaudpago SMALLINT,
  monto NUMERIC,
  cancelacion TEXT,
  axopago SMALLINT,
  bimini SMALLINT
) AS $$
BEGIN
  RETURN QUERY
    SELECT p.cvepago, p.cvecuenta, p.recaud, p.caja, p.folio, p.fecha, p.hora, p.importe, p.cajero, p.cvecanc, p.cveconcepto,
      CASE WHEN p.cvecanc > 0 THEN 'CANCELADO' ELSE NULL END AS mensaje,
      a.cvectaapl, a.recaudpago, a.monto, a.cancelacion, a.axopago, a.bimini
    FROM pagos p
    JOIN auditoria a ON p.cvepago = a.cvepago
    WHERE p.caja = p_caja AND p.recaud = p_recaud AND p.fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;