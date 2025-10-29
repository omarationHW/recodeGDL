-- Stored Procedure: sp_busque_search_by_cadastral_key
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por clave catastral (zona, manzana, predio, subpredio).
-- Generado para formulario: busque
-- Fecha: 2025-08-27 16:29:20

CREATE OR REPLACE FUNCTION sp_busque_search_by_cadastral_key(p_zone TEXT, p_block TEXT, p_lot TEXT, p_subproperty TEXT)
RETURNS TABLE(
    cvecatnva TEXT,
    subpredio SMALLINT,
    cvecuenta INTEGER,
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    capturista TEXT,
    cvecont INTEGER,
    nombre_completo TEXT,
    extviv TEXT,
    intviv TEXT,
    callevive TEXT,
    extcasa TEXT,
    intcasa TEXT,
    callecasa TEXT,
    porcentaje FLOAT,
    encabeza TEXT,
    descripcion TEXT,
    rfc TEXT
) AS $$
DECLARE
    clave TEXT;
BEGIN
    clave := p_zone || p_block || COALESCE(p_lot, '*');
    RETURN QUERY
    SELECT a.cvecatnva, a.subpredio, a.cvecuenta, a.recaud, a.urbrus, a.cuenta, b.capturista, c.cvecont, d.nombre_completo,
           d.noexterior, d.interior, d.calle, f.noexterior, f.interior, f.calle, c.porcentaje, c.encabeza, h.descripcion, d.rfc
    FROM convcta a
    JOIN catastro b ON b.cvecuenta = a.cvecuenta
    JOIN regprop c ON c.cvecuenta = a.cvecuenta AND c.cveregprop = b.cveregprop AND c.encabeza = 'S'
    JOIN contrib d ON d.cvecont = c.cvecont
    JOIN ubicacion f ON f.cvecuenta = a.cvecuenta AND f.vigencia = 'V'
    LEFT JOIN c_calidpro h ON h.cvereg = c.cvereg
    WHERE a.cvecatnva LIKE clave || '%'
      AND (a.subpredio = p_subproperty::SMALLINT OR p_subproperty IS NULL)
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;