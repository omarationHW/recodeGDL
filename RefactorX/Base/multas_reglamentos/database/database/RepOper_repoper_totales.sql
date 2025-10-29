-- Stored Procedure: repoper_totales
-- Tipo: Report
-- Descripción: Obtiene los totales de operaciones por caja, recaudadora y fecha.
-- Generado para formulario: RepOper
-- Fecha: 2025-08-27 14:28:37

CREATE OR REPLACE FUNCTION repoper_totales(p_fecha DATE, p_recaud INTEGER, p_caja TEXT)
RETURNS TABLE(
  canceladas INTEGER,
  total_canc NUMERIC,
  cheques INTEGER,
  tot_cheq NUMERIC,
  doc_cero INTEGER,
  tot_total NUMERIC,
  tot_efec NUMERIC,
  puro_efec INTEGER,
  puro_efec2 INTEGER,
  num_oper INTEGER
) AS $$
BEGIN
  -- Canceladas y total canceladas
  SELECT COUNT(*), COALESCE(SUM(importe),0) INTO canceladas, total_canc
  FROM pagos
  WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha AND cvecanc IS NOT NULL;

  -- Cheques
  SELECT COUNT(*) INTO cheques
  FROM pagos a
  JOIN cheqpag c ON a.cvepago = c.cvepago AND a.importe = c.importe
  WHERE a.caja = p_caja AND a.recaud = p_recaud AND a.fecha = p_fecha AND a.cvecanc IS NULL;

  -- Doc cero
  SELECT COUNT(*) INTO doc_cero
  FROM pagos
  WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha AND cvecanc IS NULL AND importe = 0;

  -- Totales
  SELECT COALESCE(SUM(pagos.importe),0), COALESCE(SUM(cheqpag.importe),0), COALESCE(SUM(pagos.importe),0)-COALESCE(SUM(cheqpag.importe),0)
    INTO tot_total, tot_cheq, tot_efec
  FROM pagos
  LEFT JOIN cheqpag ON pagos.cvepago = cheqpag.cvepago
  WHERE pagos.caja = p_caja AND pagos.recaud = p_recaud AND pagos.fecha = p_fecha AND pagos.cvecanc IS NULL;

  -- Puro efectivo
  SELECT COUNT(*) INTO puro_efec
  FROM pagos
  WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha AND NOT EXISTS (
    SELECT 1 FROM cheqpag WHERE cheqpag.cvepago = pagos.cvepago
  );

  -- Puro efectivo 2
  SELECT COUNT(*) INTO puro_efec2
  FROM pagos
  JOIN cheqpag ON pagos.cvepago = cheqpag.cvepago
  WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha AND pagos.importe != cheqpag.importe;

  -- Número de operaciones
  SELECT COUNT(*) INTO num_oper
  FROM pagos
  WHERE caja = p_caja AND recaud = p_recaud AND fecha = p_fecha AND cvecanc IS NULL;

  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;