-- Stored Procedure: sp_get_pagos_detalle
-- Tipo: Report
-- Descripción: Obtiene el detalle de pagos para una caja, recaudadora y fecha, incluyendo datos de convcta.
-- Generado para formulario: ListAna
-- Fecha: 2025-08-27 12:52:10

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