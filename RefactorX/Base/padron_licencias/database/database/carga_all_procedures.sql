-- ============================================
-- STORED PROCEDURES CONSOLIDADOS
-- Formulario: carga
-- Generado: 2025-08-27 16:36:45
-- Total SPs: 7
-- ============================================

-- SP 1/7: get_predio_by_clave_catastral
-- Tipo: CRUD
-- Descripción: Obtiene los datos completos del predio por clave catastral y subpredio.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_predio_by_clave_catastral(p_cvecatnva VARCHAR, p_subpredio INTEGER)
RETURNS TABLE(
    cvecatnva VARCHAR,
    subpredio INTEGER,
    cuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    propietario VARCHAR,
    ubicacion VARCHAR,
    colonia VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecatnva, c.subpredio, c.cuenta, c.recaud, c.urbrus, p.nombre_completo AS propietario,
           u.calle AS ubicacion, u.colonia, u.noexterior, u.interior, a.supterr, a.supconst, a.valorterr, a.valorconst, a.valfiscal
    FROM convcta c
    LEFT JOIN catastro a ON a.cvecuenta = c.cvecuenta
    LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
    LEFT JOIN (
        SELECT cvecuenta, MAX(CONCAT(paterno, ' ', materno, ' ', nombres)) AS nombre_completo
        FROM contrib
        GROUP BY cvecuenta
    ) p ON p.cvecuenta = c.cvecuenta
    WHERE c.cvecatnva = p_cvecatnva AND c.subpredio = p_subpredio AND c.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 2/7: get_predio_by_cuenta
-- Tipo: CRUD
-- Descripción: Obtiene los datos completos del predio por cuenta (recaud, urbrus, cuenta).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_predio_by_cuenta(p_recaud INTEGER, p_urbrus VARCHAR, p_cuenta INTEGER)
RETURNS TABLE(
    cvecatnva VARCHAR,
    subpredio INTEGER,
    cuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    propietario VARCHAR,
    ubicacion VARCHAR,
    colonia VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT c.cvecatnva, c.subpredio, c.cuenta, c.recaud, c.urbrus, p.nombre_completo AS propietario,
           u.calle AS ubicacion, u.colonia, u.noexterior, u.interior, a.supterr, a.supconst, a.valorterr, a.valorconst, a.valfiscal
    FROM convcta c
    LEFT JOIN catastro a ON a.cvecuenta = c.cvecuenta
    LEFT JOIN ubicacion u ON u.cvecuenta = c.cvecuenta
    LEFT JOIN (
        SELECT cvecuenta, MAX(CONCAT(paterno, ' ', materno, ' ', nombres)) AS nombre_completo
        FROM contrib
        GROUP BY cvecuenta
    ) p ON p.cvecuenta = c.cvecuenta
    WHERE c.recaud = p_recaud AND c.urbrus = p_urbrus AND c.cuenta = p_cuenta AND c.vigente = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 3/7: get_cartografia_predial
-- Tipo: Report
-- Descripción: Devuelve la información cartográfica asociada a un predio (simulación, ya que el acceso a archivos shape es externo).
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_cartografia_predial(p_cvecatnva VARCHAR)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    -- Simulación: en producción, aquí se integraría con un microservicio de GIS
    result := json_build_object(
        'cvecatnva', p_cvecatnva,
        'layers', ARRAY['predios', 'construcciones', 'calles', 'numeros_oficiales'],
        'status', 'ok',
        'message', 'Cartografía generada (simulada)'
    );
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 4/7: get_numeros_oficiales
-- Tipo: Report
-- Descripción: Devuelve los números oficiales de una manzana.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_numeros_oficiales(p_cvemanz VARCHAR)
RETURNS TABLE(
    cvecatnva VARCHAR,
    num VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT b.cvecatnva, CASE WHEN a.interior = '00000' OR a.interior = '' THEN a.noexterior ELSE a.noexterior || '-' || a.interior END AS num
    FROM ubicacion a
    JOIN convcta b ON b.cvecatnva LIKE p_cvemanz || '%' AND b.vigente = 'V'
    WHERE a.cvecuenta = b.cvecuenta AND a.vigencia = 'V';
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 5/7: get_condominio
-- Tipo: Catalog
-- Descripción: Devuelve los datos del condominio asociado a una clave catastral.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_condominio(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cvecond INTEGER,
    nombre VARCHAR,
    tipocond VARCHAR,
    numpred INTEGER,
    escritura INTEGER,
    idnotaria INTEGER,
    fecescrit DATE,
    cvecatnva VARCHAR,
    areacomun NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvecond, nombre, tipocond, numpred, escritura, idnotaria, fecescrit, cvecatnva, areacomun
    FROM condominio
    WHERE cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 6/7: get_avaluo
-- Tipo: Report
-- Descripción: Devuelve los datos de avalúo para una clave catastral.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_avaluo(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cveavaluo INTEGER,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC,
    perimetro NUMERIC,
    frente NUMERIC,
    profund NUMERIC,
    factor NUMERIC,
    valorunit NUMERIC,
    indiviso NUMERIC,
    frentedis NUMERIC,
    factorajus NUMERIC,
    feccap DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT cveavaluo, supterr, supconst, valorterr, valorconst, valfiscal, perimetro, frente, profund, factor, valorunit, indiviso, frentedis, factorajus, feccap
    FROM avaluos
    WHERE cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;

-- ============================================

-- SP 7/7: get_construcciones
-- Tipo: Report
-- Descripción: Devuelve las construcciones asociadas a una clave catastral.
-- --------------------------------------------

CREATE OR REPLACE FUNCTION get_construcciones(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cvebloque INTEGER,
    cveavaluo INTEGER,
    cveclasif INTEGER,
    estructura INTEGER,
    areaconst NUMERIC,
    importe NUMERIC,
    factorajus NUMERIC,
    vigente VARCHAR,
    descripcion VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT cvebloque, cveavaluo, cveclasif, estructura, areaconst, importe, factorajus, vigente, descripcion
    FROM construc
    WHERE cvecatnva = p_cvecatnva;
END;
$$ LANGUAGE plpgsql;

-- ============================================

