-- Stored Procedure: conveniosempresas
-- Tipo: Report
-- Descripción: Obtiene convenios de empresas por año y fecha
-- Generado para formulario: ListadoMultiple
-- Fecha: 2025-08-27 12:49:10

CREATE OR REPLACE FUNCTION conveniosempresas(paxo integer, pfecha date)
RETURNS TABLE(
  cvecuenta integer,
  cuenta varchar,
  folioreq integer,
  req_emision date,
  req_vig varchar,
  despacho varchar,
  conv_inicio date,
  conv_vig varchar,
  req_pagado numeric,
  conv_pagado numeric,
  parcialidad integer,
  importe_parcial numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT cvecuenta, cuenta, folioreq, req_emision, req_vig, despacho, conv_inicio, conv_vig, req_pagado, conv_pagado, parcialidad, importe_parcial
  FROM conveniosempresas_view
  WHERE EXTRACT(YEAR FROM req_emision) = paxo AND req_emision >= pfecha;
END;
$$ LANGUAGE plpgsql;