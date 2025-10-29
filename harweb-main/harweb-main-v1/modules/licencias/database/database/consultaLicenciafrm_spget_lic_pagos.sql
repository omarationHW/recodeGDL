-- Stored Procedure: spget_lic_pagos
-- Tipo: Report
-- Descripción: Obtiene los pagos de una licencia.
-- Generado para formulario: consultaLicenciafrm
-- Fecha: 2025-08-27 17:25:29

CREATE OR REPLACE FUNCTION spget_lic_pagos(p_id_licencia integer)
RETURNS TABLE(
  cvepago integer,
  cvecuenta integer,
  recaud smallint,
  caja varchar,
  folio integer,
  fecha date,
  hora timestamp,
  importe numeric,
  cajero varchar,
  cvecanc integer,
  cveconcepto integer
) AS $$
BEGIN
  RETURN QUERY
    SELECT cvepago, cvecuenta, recaud, caja, folio, fecha, hora, importe, cajero, cvecanc, cveconcepto
    FROM pagos
    WHERE cvecuenta = p_id_licencia AND cveconcepto IN (8,27,28) AND cvecanc IS NULL
    ORDER BY fecha DESC;
END;
$$ LANGUAGE plpgsql;