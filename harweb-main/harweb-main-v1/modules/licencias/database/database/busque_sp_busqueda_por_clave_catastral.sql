-- Stored Procedure: sp_busqueda_por_clave_catastral
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por clave catastral (zona, manzana, predio, subpredio).
-- Generado para formulario: busque
-- Fecha: 2025-08-27 20:41:21

CREATE OR REPLACE FUNCTION sp_busqueda_por_clave_catastral(p_zona TEXT, p_manzana TEXT, p_predio TEXT, p_subpredio TEXT)
RETURNS TABLE(
    cuenta_cat TEXT,
    subpredio SMALLINT,
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    callecasa TEXT,
    extcasa TEXT,
    intcasa TEXT,
    nombre_completo TEXT,
    callevive TEXT,
    extviv TEXT,
    intviv TEXT,
    rfc TEXT,
    descripcion TEXT,
    encabeza TEXT,
    porcentaje FLOAT
) AS $$
DECLARE
    clave TEXT;
BEGIN
    clave := p_zona || p_manzana || COALESCE(p_predio, '*');
    RETURN QUERY
    SELECT a.cvecatnva || a.subpredio AS cuenta_cat, a.subpredio, a.recaud, a.urbrus, a.cuenta,
           f.calle, f.noexterior, f.interior, d.nombre_completo, d.calle, d.noexterior, d.interior, d.rfc,
           h.descripcion, c.encabeza, c.porcentaje
    FROM convcta a
    JOIN catastro b ON b.cvecuenta = a.cvecuenta
    JOIN regprop c ON c.cvecuenta = a.cvecuenta
    JOIN contrib d ON d.cvecont = c.cvecont
    JOIN ubicacion f ON f.cvecuenta = a.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = c.cvereg
    WHERE a.cvecatnva LIKE clave || '%'
      AND (p_subpredio IS NULL OR a.subpredio::TEXT = p_subpredio)
    ORDER BY a.cvecatnva, a.subpredio
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;