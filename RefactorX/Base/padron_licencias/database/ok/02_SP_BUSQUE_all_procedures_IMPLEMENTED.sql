-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA SISTEMA DE BÚSQUEDA CATASTRAL
-- Convención: SP_BUSQUE_XXX
-- Implementado: 2025-11-20
-- Tablas: convcta, contrib, regprop, ubicacion, catastro, c_calidpro
-- Módulo: 02 - BUSQUE (Prioridad Alta)
-- ============================================

-- ============================================
-- SP 1/5: sp_busqueda_por_nombre
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por nombre completo del propietario
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_busqueda_por_nombre(p_nombre TEXT)
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
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.cvecont,
        b.nombre_completo,
        b.noexterior,
        b.interior,
        b.calle,
        c.cvecatnva,
        c.cuenta,
        c.urbrus,
        c.recaud,
        c.subpredio,
        c.vigente,
        d.calle,
        d.noexterior,
        d.interior,
        g.cveregprop,
        g.cvecuenta,
        g.cveubic,
        a.encabeza,
        h.descripcion,
        a.porcentaje,
        b.rfc
    FROM regprop a
    JOIN contrib b ON b.cvecont = a.cvecont
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    JOIN ubicacion d ON d.cveubic = c.cveubic
    JOIN catastro g ON g.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.nombre_completo ILIKE '%' || p_nombre || '%'
      AND a.encabeza = 'S'
    ORDER BY b.nombre_completo
    LIMIT 300;
END;
$$;

COMMENT ON FUNCTION public.sp_busqueda_por_nombre(TEXT) IS 'Busca cuentas catastrales por nombre del propietario';

-- ============================================
-- SP 2/5: sp_busqueda_por_ubicacion
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por calle y número exterior
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_busqueda_por_ubicacion(
    p_calle TEXT,
    p_exterior TEXT DEFAULT ''
)
RETURNS TABLE(
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    cvecuenta INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.calle,
        u.noexterior,
        u.interior,
        u.cvecuenta
    FROM ubicacion u
    WHERE u.calle ILIKE '%' || p_calle || '%'
      AND (p_exterior = '' OR u.noexterior ILIKE '%' || p_exterior || '%')
      AND u.vigencia = 'V'
    ORDER BY u.calle, u.noexterior
    LIMIT 300;
END;
$$;

COMMENT ON FUNCTION public.sp_busqueda_por_ubicacion(TEXT, TEXT) IS 'Busca cuentas catastrales por ubicación (calle y número)';

-- ============================================
-- SP 3/5: sp_busqueda_por_clave_catastral
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por clave catastral (zona, manzana, predio, subpredio)
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_busqueda_por_clave_catastral(
    p_zona TEXT,
    p_manzana TEXT,
    p_predio TEXT DEFAULT NULL,
    p_subpredio TEXT DEFAULT NULL
)
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
)
LANGUAGE plpgsql
AS $$
DECLARE
    clave TEXT;
BEGIN
    -- Construir clave catastral
    clave := p_zona || p_manzana || COALESCE(p_predio, '*');

    RETURN QUERY
    SELECT
        a.cvecatnva || a.subpredio::TEXT AS cuenta_cat,
        a.subpredio,
        a.recaud,
        a.urbrus,
        a.cuenta,
        f.calle,
        f.noexterior,
        f.interior,
        d.nombre_completo,
        d.calle,
        d.noexterior,
        d.interior,
        d.rfc,
        h.descripcion,
        c.encabeza,
        c.porcentaje
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
$$;

COMMENT ON FUNCTION public.sp_busqueda_por_clave_catastral(TEXT, TEXT, TEXT, TEXT) IS 'Busca cuentas por clave catastral completa';

-- ============================================
-- SP 4/5: sp_busqueda_por_rfc
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por RFC del propietario
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_busqueda_por_rfc(p_rfc TEXT)
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
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.rfc,
        b.nombre_completo,
        c.recaud,
        c.urbrus,
        c.cuenta,
        d.calle,
        d.noexterior,
        d.interior,
        c.cvecatnva,
        c.subpredio,
        b.calle,
        b.noexterior,
        b.interior,
        h.descripcion,
        a.porcentaje,
        a.encabeza
    FROM regprop a
    JOIN contrib b ON b.cvecont = a.cvecont
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    JOIN ubicacion d ON d.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.rfc ILIKE '%' || p_rfc || '%'
    ORDER BY b.rfc
    LIMIT 300;
END;
$$;

COMMENT ON FUNCTION public.sp_busqueda_por_rfc(TEXT) IS 'Busca cuentas catastrales por RFC del contribuyente';

-- ============================================
-- SP 5/5: sp_busqueda_por_cuenta
-- Tipo: Report
-- Descripción: Busca cuentas catastrales por recaudadora, urbano/rústico y número de cuenta
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_busqueda_por_cuenta(
    p_recaud INTEGER,
    p_urbrus TEXT,
    p_cuenta INTEGER
)
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
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.recaud,
        a.urbrus,
        a.cuenta,
        a.cvecatnva,
        a.subpredio,
        d.calle,
        d.noexterior,
        d.interior,
        b.nombre_completo,
        b.rfc
    FROM convcta a
    JOIN regprop c ON c.cvecuenta = a.cvecuenta
    JOIN contrib b ON b.cvecont = c.cvecont
    JOIN ubicacion d ON d.cvecuenta = a.cvecuenta
    WHERE a.recaud = p_recaud
      AND a.urbrus = p_urbrus
      AND a.cuenta = p_cuenta
    LIMIT 300;
END;
$$;

COMMENT ON FUNCTION public.sp_busqueda_por_cuenta(INTEGER, TEXT, INTEGER) IS 'Busca cuenta catastral específica por recaudadora/urbrus/cuenta';

-- ============================================
-- FUNCIONES ADICIONALES PARA API GENÉRICO
-- ============================================

-- SP ADICIONAL: sp_busque_search_by_owner (Alias para API)
CREATE OR REPLACE FUNCTION public.sp_busque_search_by_owner(p_name TEXT)
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
    cvecalle INTEGER,
    encabeza TEXT,
    descripcion TEXT,
    porcentaje FLOAT,
    rfc TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        a.cvecont,
        b.nombre_completo,
        b.noexterior,
        b.interior,
        b.calle,
        c.cvecatnva,
        c.cuenta,
        c.urbrus,
        c.recaud,
        c.subpredio,
        c.vigente,
        d.calle,
        d.noexterior,
        d.interior,
        g.cveregprop,
        g.cvecuenta,
        g.cveubic,
        d.cvecalle,
        a.encabeza,
        h.descripcion,
        a.porcentaje,
        b.rfc
    FROM regprop a
    JOIN contrib b ON b.cvecont = a.cvecont
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    JOIN ubicacion d ON d.cveubic = c.cveubic
    JOIN catastro g ON g.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.nombre_completo ILIKE '%' || p_name || '%'
      AND a.encabeza = 'S'
    ORDER BY b.nombre_completo
    LIMIT 300;
END;
$$;

COMMENT ON FUNCTION public.sp_busque_search_by_owner(TEXT) IS 'Alias de sp_busqueda_por_nombre para API genérico';

-- SP ADICIONAL: sp_busque_search_by_account (Alias para API)
CREATE OR REPLACE FUNCTION public.sp_busque_search_by_account(
    p_recaud TEXT,
    p_urbrus TEXT,
    p_cuenta TEXT
)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva TEXT,
    subpredio SMALLINT,
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    vigente TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cvecuenta,
        c.cvecatnva,
        c.subpredio,
        c.recaud,
        c.urbrus,
        c.cuenta,
        c.vigente
    FROM convcta c
    WHERE c.recaud = p_recaud::SMALLINT
      AND c.urbrus = p_urbrus
      AND c.cuenta = p_cuenta::INTEGER
    LIMIT 300;
END;
$$;

COMMENT ON FUNCTION public.sp_busque_search_by_account(TEXT, TEXT, TEXT) IS 'Busca cuenta catastral - Alias para API genérico';

-- SP ADICIONAL: sp_busque_get_detail (Obtiene detalle completo)
CREATE OR REPLACE FUNCTION public.sp_busque_get_detail(
    p_recaud TEXT,
    p_urbrus TEXT,
    p_cuenta TEXT
)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvecatnva TEXT,
    subpredio SMALLINT,
    recaud SMALLINT,
    urbrus TEXT,
    cuenta INTEGER,
    vigente TEXT,
    detalle JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.cvecuenta,
        c.cvecatnva,
        c.subpredio,
        c.recaud,
        c.urbrus,
        c.cuenta,
        c.vigente,
        to_jsonb(c.*) as detalle
    FROM convcta c
    WHERE c.recaud = p_recaud::SMALLINT
      AND c.urbrus = p_urbrus
      AND c.cuenta = p_cuenta::INTEGER
    LIMIT 1;
END;
$$;

COMMENT ON FUNCTION public.sp_busque_get_detail(TEXT, TEXT, TEXT) IS 'Obtiene detalle completo de cuenta catastral';

-- SP ADICIONAL: sp_busque_search_by_location (Alias para API)
CREATE OR REPLACE FUNCTION public.sp_busque_search_by_location(
    p_calle TEXT,
    p_exterior TEXT DEFAULT ''
)
RETURNS TABLE(
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    cvecuenta INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.calle,
        u.noexterior,
        u.interior,
        u.cvecuenta
    FROM ubicacion u
    WHERE u.calle ILIKE '%' || p_calle || '%'
      AND (p_exterior = '' OR u.noexterior ILIKE '%' || p_exterior || '%')
      AND u.vigencia = 'V'
    ORDER BY u.calle, u.noexterior
    LIMIT 300;
END;
$$;

COMMENT ON FUNCTION public.sp_busque_search_by_location(TEXT, TEXT) IS 'Busca por ubicación - Alias para API genérico';

-- SP ADICIONAL: sp_busque_search_by_cadastral_key (Alias para API)
CREATE OR REPLACE FUNCTION public.sp_busque_search_by_cadastral_key(
    p_zona TEXT,
    p_manzana TEXT,
    p_predio TEXT DEFAULT NULL,
    p_subpredio TEXT DEFAULT NULL
)
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
)
LANGUAGE plpgsql
AS $$
DECLARE
    clave TEXT;
BEGIN
    clave := p_zona || p_manzana || COALESCE(p_predio, '*');

    RETURN QUERY
    SELECT
        a.cvecatnva || a.subpredio::TEXT AS cuenta_cat,
        a.subpredio,
        a.recaud,
        a.urbrus,
        a.cuenta,
        f.calle,
        f.noexterior,
        f.interior,
        d.nombre_completo,
        d.calle,
        d.noexterior,
        d.interior,
        d.rfc,
        h.descripcion,
        c.encabeza,
        c.porcentaje
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
$$;

COMMENT ON FUNCTION public.sp_busque_search_by_cadastral_key(TEXT, TEXT, TEXT, TEXT) IS 'Busca por clave catastral - Alias para API genérico';

-- SP ADICIONAL: sp_busque_search_by_rfc (Alias para API)
CREATE OR REPLACE FUNCTION public.sp_busque_search_by_rfc(p_rfc TEXT)
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
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.rfc,
        b.nombre_completo,
        c.recaud,
        c.urbrus,
        c.cuenta,
        d.calle,
        d.noexterior,
        d.interior,
        c.cvecatnva,
        c.subpredio,
        b.calle,
        b.noexterior,
        b.interior,
        h.descripcion,
        a.porcentaje,
        a.encabeza
    FROM regprop a
    JOIN contrib b ON b.cvecont = a.cvecont
    JOIN convcta c ON c.cvecuenta = a.cvecuenta
    JOIN ubicacion d ON d.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.rfc ILIKE '%' || p_rfc || '%'
    ORDER BY b.rfc
    LIMIT 300;
END;
$$;

COMMENT ON FUNCTION public.sp_busque_search_by_rfc(TEXT) IS 'Busca por RFC - Alias para API genérico';

-- ============================================
-- COMENTARIOS DE IMPLEMENTACIÓN
-- ============================================

/*
IMPLEMENTACIÓN COMPLETADA - 2025-11-20

Stored Procedures implementados: 11 SPs
- 5 SPs principales de búsqueda catastral
- 6 SPs alias para compatibilidad con API genérico

Tablas utilizadas (schema public):
- convcta: Conversión de cuentas catastrales
- contrib: Contribuyentes/propietarios
- regprop: Registro de propietarios
- ubicacion: Ubicaciones/domicilios
- catastro: Información catastral
- c_calidpro: Catálogo de calidad de propiedad

Funcionalidades implementadas:
1. Búsqueda por nombre de propietario (ILIKE)
2. Búsqueda por ubicación (calle + número)
3. Búsqueda por clave catastral (zona-manzana-predio-subpredio)
4. Búsqueda por RFC
5. Búsqueda por cuenta (recaud-urbrus-cuenta)
6. Obtención de detalle completo con JSONB

Características:
- LIMIT 300 en todas las búsquedas
- LEFT JOIN para tablas opcionales
- ILIKE para búsquedas case-insensitive
- ORDER BY para resultados ordenados
- Compatibilidad total con API genérico
- RETURNS TABLE para compatibilidad
- Manejo de parámetros NULL

Uso desde API genérico:
POST /api/generic
{
  "eRequest": {
    "Operacion": "sp_busque_search_by_owner",
    "Base": "padron_licencias",
    "Esquema": "public",
    "Parametros": [
      {"nombre": "p_name", "valor": "GARCIA", "tipo": "text"}
    ]
  }
}
*/
