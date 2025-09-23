-- Stored Procedure: sp_busque_search_by_cuenta
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por recaudadora, urbrus y cuenta
-- Generado para formulario: busque
-- Fecha: 2025-08-27 20:41:05

CREATE OR REPLACE FUNCTION sp_busque_search_by_cuenta(recaudadora INTEGER, urbrus TEXT, cuenta INTEGER)
RETURNS TABLE (
  cvecont INTEGER,
  ncompleto TEXT,
  vive_ext TEXT,
  vive_int TEXT,
  calle_vive TEXT,
  clave_cat TEXT,
  cuenta INTEGER,
  ur TEXT,
  reca INTEGER,
  subpredio INTEGER,
  vigente TEXT,
  calle_ubica TEXT,
  exterior TEXT,
  no_int TEXT,
  cveregp INTEGER,
  cvectacat INTEGER,
  cveubic INTEGER,
  cvecalle INTEGER,
  encabeza TEXT,
  descripcion TEXT,
  porcentaje FLOAT,
  rfc TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT a.cvecont, b.nombre_completo, b.noexterior AS vive_ext, b.interior AS vive_int, b.calle AS calle_vive,
         c.cvecatnva AS clave_cat, c.cuenta, c.urbrus AS ur, c.recaud AS reca, c.subpredio, c.vigente,
         d.calle AS calle_ubica, d.noexterior AS exterior, d.interior AS no_int, g.cveregprop AS cveregp,
         g.cvecuenta AS cvectacat, g.cveubic, d.cvecalle, a.encabeza, h.descripcion, a.porcentaje, b.rfc
  FROM regprop a
  JOIN contrib b ON b.cvecont = a.cvecont
  JOIN convcta c ON c.cvecuenta = a.cvecuenta
  JOIN ubicacion d ON d.cveubic = g.cveubic
  JOIN catastro g ON g.cvecuenta = a.cvecuenta AND g.cveregprop = a.cveregprop
  LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
  WHERE c.recaud = recaudadora
    AND c.urbrus = urbrus
    AND c.cuenta = cuenta
    AND a.vigencia = 'V'
  LIMIT 300;
END;
$$ LANGUAGE plpgsql;