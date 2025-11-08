-- Stored Procedure: propuestatab_list
-- Tipo: CRUD
-- Descripción: Obtiene los datos principales de la cuenta histórica
-- Generado para formulario: Propuestatab
-- Fecha: 2025-08-27 18:59:08

CREATE OR REPLACE FUNCTION propuestatab_list(p_cvecuenta INTEGER)
RETURNS TABLE(
  cvecuenta INTEGER,
  cvecatnva VARCHAR,
  subpredio INTEGER,
  cmovto VARCHAR,
  observacion TEXT,
  tasa NUMERIC,
  indiviso NUMERIC,
  calle VARCHAR,
  noexterior VARCHAR,
  interior VARCHAR,
  colonia VARCHAR,
  vigencia VARCHAR,
  obsinter TEXT,
  fechaotorg DATE,
  importe NUMERIC,
  valortransm NUMERIC,
  areatitulo NUMERIC,
  notario VARCHAR,
  noescrituras INTEGER,
  recaud INTEGER,
  urbrus VARCHAR,
  cuenta INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.cvecuenta, c.cvecatnva, c.subpredio, c.cmovto, c.observacion, v.tasa, c.indiviso,
         u.calle, u.noexterior, u.interior, u.colonia, u.vigencia, u.obsinter,
         a.fechaotorg, p.importe, p.valortransm, h.areatitulo, n.notario, p.noescrituras,
         c.recaud, c.urbrus, c.cuenta
  FROM cuentas c
  LEFT JOIN valores v ON v.cvecuenta = c.cvecuenta
  LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
  LEFT JOIN pagos p ON p.cvecuenta = c.cvecuenta
  LEFT JOIN historico h ON h.cvecuenta = c.cvecuenta
  LEFT JOIN notarios n ON n.idnotaria = p.idnotaria
  WHERE c.cvecuenta = p_cvecuenta
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;