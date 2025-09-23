-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: busque
-- Generado: 2025-08-27 20:41:05
-- Total SPs: 5
-- ============================================

-- SP 1/5: sp_busque_search_by_name
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por nombre de propietario (LIKE, máximo 300 resultados)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busque_search_by_name(nombre TEXT)
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
  WHERE b.nombre_completo ILIKE '%' || nombre || '%'
    AND a.vigencia = 'V'
  ORDER BY b.nombre_completo
  LIMIT 300;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/5: sp_busque_search_by_location
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por ubicación (calle y número exterior, máximo 300 resultados)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busque_search_by_location(calle TEXT, exterior TEXT)
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
  WHERE d.calle ILIKE '%' || calle || '%'
    AND (d.noexterior ILIKE '%' || exterior || '%' OR exterior = '' OR exterior IS NULL)
    AND a.vigencia = 'V'
  ORDER BY d.calle, d.noexterior
  LIMIT 300;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/5: sp_busque_search_by_clave_catastral
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por clave catastral (zona, manzana, predio, subpredio)
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busque_search_by_clave_catastral(zona TEXT, manzana TEXT, predio TEXT, subpredio TEXT)
RETURNS TABLE (
  cuenta_cat TEXT,
  subpredio INTEGER,
  cvecuenta INTEGER,
  recaud INTEGER,
  urbrus TEXT,
  cuenta INTEGER,
  nombre_completo TEXT,
  callevive TEXT,
  extviv TEXT,
  intviv TEXT,
  callecasa TEXT,
  extcasa TEXT,
  intcasa TEXT,
  rfc TEXT,
  descripcion TEXT,
  encabeza TEXT,
  porcentaje FLOAT
) AS $$
DECLARE
  clave TEXT;
BEGIN
  IF predio IS NULL OR predio = '' THEN
    clave := zona || manzana || '%';
  ELSE
    clave := zona || manzana || predio;
  END IF;
  RETURN QUERY
  SELECT a.cvecatnva AS cuenta_cat, a.subpredio, a.cvecuenta, a.recaud, a.urbrus, a.cuenta,
         d.nombre_completo, d.calle AS callevive, d.noexterior AS extviv, d.interior AS intviv,
         f.calle AS callecasa, f.noexterior AS extcasa, f.interior AS intcasa, d.rfc,
         h.descripcion, c.encabeza, c.porcentaje
  FROM convcta a
  JOIN catastro b ON b.cvecuenta = a.cvecuenta
  JOIN regprop c ON c.cvecuenta = a.cvecuenta AND c.cveregprop = b.cveregprop AND c.encabeza = 'S'
  JOIN contrib d ON d.cvecont = c.cvecont
  JOIN ubicacion f ON f.cvecuenta = a.cvecuenta AND f.vigencia = 'V'
  LEFT JOIN c_calidpro h ON h.cvereg = c.cvereg
  WHERE a.cvecatnva ILIKE clave
    AND (subpredio::TEXT = subpredio OR subpredio IS NULL OR subpredio = '')
  ORDER BY a.cvecatnva, a.subpredio
  LIMIT 300;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/5: sp_busque_search_by_rfc
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por RFC del propietario
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busque_search_by_rfc(rfc TEXT)
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
  WHERE b.rfc ILIKE '%' || rfc || '%'
    AND a.vigencia = 'V'
  ORDER BY b.rfc
  LIMIT 300;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/5: sp_busque_search_by_cuenta
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por recaudadora, urbrus y cuenta
-- --------------------------------------------

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

-- ============================================

