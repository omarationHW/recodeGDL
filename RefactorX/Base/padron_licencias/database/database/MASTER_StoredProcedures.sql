-- ============================================
-- SCRIPT MAESTRO DE STORED PROCEDURES
-- Proyecto: Licencias2
-- Generado: 2025-08-27 21:01:57
-- Total SPs: 5
-- ============================================

-- NOTA: Ejecutar este script en PostgreSQL para crear todos los stored procedures
-- del módulo. Se recomienda ejecutar en el siguiente orden:
-- 1. CATALOG procedures (consultas básicas)
-- 2. CRUD procedures (operaciones de datos)
-- 3. PROCESS procedures (procesos de negocio)
-- 4. REPORT procedures (reportes y análisis)

-- ============================================
-- STORED PROCEDURES TIPO: Report
-- ============================================

-- SP 1/5 del tipo Report
-- Nombre: sp_busqueda_por_clave_catastral
-- Descripción: Busca cuentas catastrales por clave catastral (zona, manzana, predio, subpredio).
-- --------------------------------------------

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

-- --------------------------------------------

-- SP 2/5 del tipo Report
-- Nombre: sp_busqueda_por_cuenta
-- Descripción: Busca cuentas catastrales por recaudadora, urbano/rústico y número de cuenta.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busqueda_por_cuenta(p_recaud INTEGER, p_urbrus TEXT, p_cuenta INTEGER)
RETURNS TABLE(
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    cvecatnva TEXT,
    subpredio SMALLINT,
    calle_ubica TEXT,
    exterior TEXT,
    no_int TEXT,
    ncompleto TEXT,
    rfc TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.recaud, a.urbrus, a.cuenta, a.cvecatnva, a.subpredio, d.calle, d.noexterior, d.interior, b.nombre_completo, b.rfc
    FROM convcta a
    JOIN regprop c ON c.cvecuenta = a.cvecuenta
    JOIN contrib b ON b.cvecont = c.cvecont
    JOIN ubicacion d ON d.cvecuenta = a.cvecuenta
    WHERE a.recaud = p_recaud
      AND a.urbrus = p_urbrus
      AND a.cuenta = p_cuenta
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 3/5 del tipo Report
-- Nombre: sp_busqueda_por_nombre
-- Descripción: Busca cuentas catastrales por nombre completo del propietario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busqueda_por_nombre(p_nombre TEXT)
RETURNS TABLE(
    cvecont INTEGER,
    ncompleto TEXT,
    vive_ext TEXT,
    vive_int TEXT,
    calle_vive TEXT,
    clave_cat TEXT,
    cuenta INTEGER,
    ur TEXT,
    reca SMALLINT,
    subpredio SMALLINT,
    vigente TEXT,
    calle_ubica TEXT,
    exterior TEXT,
    no_int TEXT,
    cveregp INTEGER,
    cvectacat INTEGER,
    cveubic INTEGER,
    encabeza TEXT,
    descripcion TEXT,
    porcentaje FLOAT,
    rfc TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.cvecont, b.nombre_completo, b.noexterior, b.interior, b.calle, c.cvecatnva, c.cuenta, c.urbrus, c.recaud, c.subpredio, c.vigente,
           d.calle, d.noexterior, d.interior, g.cveregprop, g.cvecuenta, g.cveubic, a.encabeza, h.descripcion, a.porcentaje, b.rfc
    FROM regprop a
    JOIN contrib b ON b.cvecont = a.cvecont
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    JOIN ubicacion d ON d.cveubic = c.cveubic
    JOIN catastro g ON g.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.nombre_completo ILIKE '%' || p_nombre || '%'
      AND a.encabeza = 'S'
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 4/5 del tipo Report
-- Nombre: sp_busqueda_por_rfc
-- Descripción: Busca cuentas catastrales por RFC del propietario.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busqueda_por_rfc(p_rfc TEXT)
RETURNS TABLE(
    rfc TEXT,
    ncompleto TEXT,
    recaud SMALLINT,
    ur TEXT,
    cuenta INTEGER,
    calle_ubica TEXT,
    exterior TEXT,
    no_int TEXT,
    clave_cat TEXT,
    subpredio SMALLINT,
    calle_vive TEXT,
    vive_ext TEXT,
    vive_int TEXT,
    descripcion TEXT,
    porcentaje FLOAT,
    encabeza TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.rfc, b.nombre_completo, c.recaud, c.urbrus, c.cuenta, d.calle, d.noexterior, d.interior, c.cvecatnva, c.subpredio,
           b.calle, b.noexterior, b.interior, h.descripcion, a.porcentaje, a.encabeza
    FROM regprop a
    JOIN contrib b ON b.cvecont = a.cvecont
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    JOIN ubicacion d ON d.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.rfc ILIKE '%' || p_rfc || '%'
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- SP 5/5 del tipo Report
-- Nombre: sp_busqueda_por_ubicacion
-- Descripción: Busca cuentas catastrales por calle y número exterior.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION sp_busqueda_por_ubicacion(p_calle TEXT, p_exterior TEXT)
RETURNS TABLE(
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    cvecuenta INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT calle, noexterior, interior, cvecuenta
    FROM ubicacion
    WHERE calle ILIKE '%' || p_calle || '%'
      AND (p_exterior = '' OR noexterior ILIKE '%' || p_exterior || '%')
      AND vigencia = 'V'
    ORDER BY calle, noexterior
    LIMIT 300;
END;
$$ LANGUAGE plpgsql;

-- --------------------------------------------

-- ============================================
-- FIN DEL SCRIPT MAESTRO
-- Total de 5 stored procedures incluidos
-- ============================================
