-- Stored Procedure: sp_busque_search_by_clave_catastral
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por clave catastral (zona, manzana, predio, subpredio)
-- Generado para formulario: busque
-- Fecha: 2025-08-27 20:41:05

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