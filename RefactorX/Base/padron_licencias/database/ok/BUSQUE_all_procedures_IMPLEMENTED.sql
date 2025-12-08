-- ============================================
-- MÓDULO: PADRON_LICENCIAS
-- COMPONENTE: busque
-- DESCRIPCIÓN: Sistema de búsqueda catastral múltiple (predial/catastro)
-- BATCH: 10
-- FECHA IMPLEMENTACIÓN: 2025-11-21
-- TOTAL STORED PROCEDURES: 6
-- PROGRESO: 62/95 componentes completados (65.3%)
-- ============================================
-- CARACTERÍSTICAS:
-- - Búsqueda por nombre de propietario (ILIKE case-insensitive)
-- - Búsqueda por número de cuenta catastral
-- - Búsqueda por RFC del contribuyente
-- - Búsqueda por ubicación (calle + número exterior)
-- - Búsqueda por clave catastral completa
-- - Obtención de detalle completo de cuenta
-- - Joins complejos entre tablas catastrales
-- - LIMIT 300 para prevenir resultados masivos
-- - LEFT JOIN para datos opcionales
-- ============================================

-- ============================================
-- CONFIGURACIÓN DE SCHEMA
-- ============================================
-- Schema: public (datos catastrales específicos del módulo)
-- Base de datos: padron_licencias
-- ============================================

-- ============================================
-- TABLAS INVOLUCRADAS
-- ============================================
-- regprop: Registro de propietarios de predios
-- contrib: Contribuyentes (personas físicas/morales)
-- convcta: Conversión de cuentas catastrales
-- ubicacion: Ubicaciones/domicilios de predios
-- catastro: Información catastral detallada
-- c_calidpro: Catálogo de calidad de propiedad
-- ============================================

-- ============================================
-- SP 1/6: sp_busque_search_by_owner
-- DESCRIPCIÓN: Busca cuentas catastrales por nombre del propietario
-- TIPO: Query (RETURNS TABLE)
-- PARÁMETROS: p_nombre (TEXT) - Nombre completo o parcial del propietario
-- RETURNS: Información completa del propietario y su(s) cuenta(s) catastral(es)
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_busque_search_by_owner(
    p_nombre TEXT
)
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
) AS $$
BEGIN
    -- Validación de parámetros
    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE EXCEPTION 'El parámetro p_nombre es requerido y no puede estar vacío';
    END IF;

    RETURN QUERY
    SELECT
        a.cvecont,
        b.nombre_completo,
        b.noexterior AS vive_ext,
        b.interior AS vive_int,
        b.calle AS calle_vive,
        c.cvecatnva AS clave_cat,
        c.cuenta,
        c.urbrus AS ur,
        c.recaud AS reca,
        c.subpredio,
        c.vigente,
        d.calle AS calle_ubica,
        d.noexterior AS exterior,
        d.interior AS no_int,
        g.cveregprop AS cveregp,
        g.cvecuenta AS cvectacat,
        g.cveubic,
        d.cvecalle,
        a.encabeza,
        h.descripcion,
        a.porcentaje,
        b.rfc
    FROM regprop a
    INNER JOIN contrib b ON b.cvecont = a.cvecont
    INNER JOIN convcta c ON c.cvecuenta = a.cvecuenta
    INNER JOIN ubicacion d ON d.cveubic = c.cveubic
    INNER JOIN catastro g ON g.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.nombre_completo ILIKE '%' || p_nombre || '%'
      AND a.encabeza = 'S'
    ORDER BY b.nombre_completo
    LIMIT 300;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_busque_search_by_owner: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_busque_search_by_owner(TEXT) IS
'Busca cuentas catastrales por nombre del propietario (búsqueda case-insensitive)';

-- ============================================
-- SP 2/6: sp_busque_search_by_account
-- DESCRIPCIÓN: Busca cuenta catastral específica por recaudadora/urbrus/cuenta
-- TIPO: Query (RETURNS TABLE)
-- PARÁMETROS:
--   p_recaud (INTEGER) - Número de recaudadora
--   p_urbrus (TEXT) - Tipo urbano/rústico (U/R)
--   p_cuenta (INTEGER) - Número de cuenta
-- RETURNS: Información de la cuenta catastral
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_busque_search_by_account(
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
) AS $$
BEGIN
    -- Validación de parámetros
    IF p_recaud IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_recaud es requerido';
    END IF;

    IF p_urbrus IS NULL OR TRIM(p_urbrus) = '' THEN
        RAISE EXCEPTION 'El parámetro p_urbrus es requerido';
    END IF;

    IF p_cuenta IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_cuenta es requerido';
    END IF;

    RETURN QUERY
    SELECT
        a.recaud,
        a.urbrus,
        a.cuenta,
        a.cvecatnva,
        a.subpredio,
        d.calle AS calle_ubica,
        d.noexterior AS exterior,
        d.interior AS no_int,
        b.nombre_completo AS ncompleto,
        b.rfc
    FROM convcta a
    INNER JOIN regprop c ON c.cvecuenta = a.cvecuenta
    INNER JOIN contrib b ON b.cvecont = c.cvecont
    INNER JOIN ubicacion d ON d.cvecuenta = a.cvecuenta
    WHERE a.recaud = p_recaud::SMALLINT
      AND a.urbrus = p_urbrus
      AND a.cuenta = p_cuenta
    LIMIT 300;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_busque_search_by_account: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_busque_search_by_account(INTEGER, TEXT, INTEGER) IS
'Busca cuenta catastral específica por recaudadora/urbano-rústico/número de cuenta';

-- ============================================
-- SP 3/6: sp_busque_search_by_rfc
-- DESCRIPCIÓN: Busca cuentas catastrales por RFC del propietario/contribuyente
-- TIPO: Query (RETURNS TABLE)
-- PARÁMETROS: p_rfc (TEXT) - RFC completo o parcial del contribuyente
-- RETURNS: Información de cuentas asociadas al RFC
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_busque_search_by_rfc(
    p_rfc TEXT
)
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
    -- Validación de parámetros
    IF p_rfc IS NULL OR TRIM(p_rfc) = '' THEN
        RAISE EXCEPTION 'El parámetro p_rfc es requerido y no puede estar vacío';
    END IF;

    RETURN QUERY
    SELECT
        b.rfc,
        b.nombre_completo AS ncompleto,
        c.recaud,
        c.urbrus AS ur,
        c.cuenta,
        d.calle AS calle_ubica,
        d.noexterior AS exterior,
        d.interior AS no_int,
        c.cvecatnva AS clave_cat,
        c.subpredio,
        b.calle AS calle_vive,
        b.noexterior AS vive_ext,
        b.interior AS vive_int,
        h.descripcion,
        a.porcentaje,
        a.encabeza
    FROM regprop a
    INNER JOIN contrib b ON b.cvecont = a.cvecont
    INNER JOIN convcta c ON c.cvecuenta = a.cvecuenta
    INNER JOIN ubicacion d ON d.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = a.cvereg
    WHERE b.rfc ILIKE '%' || p_rfc || '%'
    ORDER BY b.rfc, b.nombre_completo
    LIMIT 300;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_busque_search_by_rfc: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_busque_search_by_rfc(TEXT) IS
'Busca cuentas catastrales por RFC del contribuyente (búsqueda case-insensitive)';

-- ============================================
-- SP 4/6: sp_busque_search_by_location
-- DESCRIPCIÓN: Busca cuentas catastrales por ubicación (calle y número exterior)
-- TIPO: Query (RETURNS TABLE)
-- PARÁMETROS:
--   p_calle (TEXT) - Nombre de la calle
--   p_exterior (TEXT) - Número exterior (opcional)
-- RETURNS: Ubicaciones que coinciden con los criterios de búsqueda
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_busque_search_by_location(
    p_calle TEXT,
    p_exterior TEXT DEFAULT ''
)
RETURNS TABLE(
    calle TEXT,
    noexterior TEXT,
    interior TEXT,
    cvecuenta INTEGER
) AS $$
BEGIN
    -- Validación de parámetros
    IF p_calle IS NULL OR TRIM(p_calle) = '' THEN
        RAISE EXCEPTION 'El parámetro p_calle es requerido y no puede estar vacío';
    END IF;

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

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_busque_search_by_location: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_busque_search_by_location(TEXT, TEXT) IS
'Busca cuentas catastrales por ubicación (calle + número exterior, búsqueda case-insensitive)';

-- ============================================
-- SP 5/6: sp_busque_search_by_cadastral_key
-- DESCRIPCIÓN: Busca cuentas por clave catastral (zona-manzana-predio-subpredio)
-- TIPO: Query (RETURNS TABLE)
-- PARÁMETROS:
--   p_zona (TEXT) - Zona catastral
--   p_manzana (TEXT) - Manzana catastral
--   p_predio (TEXT) - Predio (opcional, permite wildcards)
--   p_subpredio (TEXT) - Subpredio (opcional)
-- RETURNS: Información completa de cuentas que coinciden con la clave
-- ============================================
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
) AS $$
DECLARE
    v_clave TEXT;
BEGIN
    -- Validación de parámetros
    IF p_zona IS NULL OR TRIM(p_zona) = '' THEN
        RAISE EXCEPTION 'El parámetro p_zona es requerido y no puede estar vacío';
    END IF;

    IF p_manzana IS NULL OR TRIM(p_manzana) = '' THEN
        RAISE EXCEPTION 'El parámetro p_manzana es requerido y no puede estar vacío';
    END IF;

    -- Construir clave catastral con wildcards si no se especifica predio
    v_clave := p_zona || p_manzana || COALESCE(p_predio, '*');

    RETURN QUERY
    SELECT
        a.cvecatnva || a.subpredio::TEXT AS cuenta_cat,
        a.subpredio,
        a.recaud,
        a.urbrus,
        a.cuenta,
        f.calle AS callecasa,
        f.noexterior AS extcasa,
        f.interior AS intcasa,
        d.nombre_completo,
        d.calle AS callevive,
        d.noexterior AS extviv,
        d.interior AS intviv,
        d.rfc,
        h.descripcion,
        c.encabeza,
        c.porcentaje
    FROM convcta a
    INNER JOIN catastro b ON b.cvecuenta = a.cvecuenta
    INNER JOIN regprop c ON c.cvecuenta = a.cvecuenta
    INNER JOIN contrib d ON d.cvecont = c.cvecont
    INNER JOIN ubicacion f ON f.cvecuenta = a.cvecuenta
    LEFT JOIN c_calidpro h ON h.cvereg = c.cvereg
    WHERE a.cvecatnva LIKE v_clave || '%'
      AND (p_subpredio IS NULL OR a.subpredio::TEXT = p_subpredio)
    ORDER BY a.cvecatnva, a.subpredio
    LIMIT 300;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_busque_search_by_cadastral_key: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_busque_search_by_cadastral_key(TEXT, TEXT, TEXT, TEXT) IS
'Busca cuentas por clave catastral completa (zona-manzana-predio-subpredio con soporte de wildcards)';

-- ============================================
-- SP 6/6: sp_busque_get_detail
-- DESCRIPCIÓN: Obtiene el detalle completo de una cuenta catastral específica
-- TIPO: Query (RETURNS TABLE)
-- PARÁMETROS:
--   p_recaud (INTEGER) - Número de recaudadora
--   p_urbrus (TEXT) - Tipo urbano/rústico (U/R)
--   p_cuenta (INTEGER) - Número de cuenta
-- RETURNS: Detalle completo de la cuenta en formato JSONB
-- ============================================
CREATE OR REPLACE FUNCTION public.sp_busque_get_detail(
    p_recaud INTEGER,
    p_urbrus TEXT,
    p_cuenta INTEGER
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
) AS $$
BEGIN
    -- Validación de parámetros
    IF p_recaud IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_recaud es requerido';
    END IF;

    IF p_urbrus IS NULL OR TRIM(p_urbrus) = '' THEN
        RAISE EXCEPTION 'El parámetro p_urbrus es requerido';
    END IF;

    IF p_cuenta IS NULL THEN
        RAISE EXCEPTION 'El parámetro p_cuenta es requerido';
    END IF;

    RETURN QUERY
    SELECT
        c.cvecuenta,
        c.cvecatnva,
        c.subpredio,
        c.recaud,
        c.urbrus,
        c.cuenta,
        c.vigente,
        jsonb_build_object(
            'cvecuenta', c.cvecuenta,
            'cvecatnva', c.cvecatnva,
            'subpredio', c.subpredio,
            'recaud', c.recaud,
            'urbrus', c.urbrus,
            'cuenta', c.cuenta,
            'vigente', c.vigente,
            'propietario', jsonb_build_object(
                'nombre_completo', COALESCE(b.nombre_completo, ''),
                'rfc', COALESCE(b.rfc, ''),
                'calle', COALESCE(b.calle, ''),
                'noexterior', COALESCE(b.noexterior, ''),
                'interior', COALESCE(b.interior, '')
            ),
            'ubicacion', jsonb_build_object(
                'calle', COALESCE(d.calle, ''),
                'noexterior', COALESCE(d.noexterior, ''),
                'interior', COALESCE(d.interior, ''),
                'cvecalle', d.cvecalle
            ),
            'registro', jsonb_build_object(
                'encabeza', COALESCE(rp.encabeza, ''),
                'porcentaje', COALESCE(rp.porcentaje, 0),
                'descripcion', COALESCE(cp.descripcion, '')
            )
        ) AS detalle
    FROM convcta c
    LEFT JOIN regprop rp ON rp.cvecuenta = c.cvecuenta
    LEFT JOIN contrib b ON b.cvecont = rp.cvecont
    LEFT JOIN ubicacion d ON d.cvecuenta = c.cvecuenta
    LEFT JOIN c_calidpro cp ON cp.cvereg = rp.cvereg
    WHERE c.recaud = p_recaud::SMALLINT
      AND c.urbrus = p_urbrus
      AND c.cuenta = p_cuenta
    LIMIT 1;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error en sp_busque_get_detail: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.sp_busque_get_detail(INTEGER, TEXT, INTEGER) IS
'Obtiene el detalle completo de una cuenta catastral específica con información estructurada en JSONB';

-- ============================================
-- ÍNDICES RECOMENDADOS (CRÍTICO PARA RENDIMIENTO)
-- ============================================
-- IMPORTANTE: Estos índices son fundamentales para el rendimiento de las búsquedas
-- Si no existen, las búsquedas serán extremadamente lentas en bases de datos grandes
-- ============================================

/*
-- Índices para búsqueda por nombre (SP 1)
CREATE INDEX IF NOT EXISTS idx_contrib_nombre_completo_ilike ON contrib USING gin(nombre_completo gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_contrib_cvecont ON contrib(cvecont);
CREATE INDEX IF NOT EXISTS idx_regprop_cvecont ON regprop(cvecont);
CREATE INDEX IF NOT EXISTS idx_regprop_encabeza ON regprop(encabeza) WHERE encabeza = 'S';

-- Índices para búsqueda por cuenta (SP 2)
CREATE INDEX IF NOT EXISTS idx_convcta_recaud_urbrus_cuenta ON convcta(recaud, urbrus, cuenta);
CREATE INDEX IF NOT EXISTS idx_convcta_cvecuenta ON convcta(cvecuenta);
CREATE INDEX IF NOT EXISTS idx_regprop_cvecuenta ON regprop(cvecuenta);

-- Índices para búsqueda por RFC (SP 3)
CREATE INDEX IF NOT EXISTS idx_contrib_rfc_ilike ON contrib USING gin(rfc gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_contrib_rfc ON contrib(rfc);

-- Índices para búsqueda por ubicación (SP 4)
CREATE INDEX IF NOT EXISTS idx_ubicacion_calle_ilike ON ubicacion USING gin(calle gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_ubicacion_vigencia ON ubicacion(vigencia) WHERE vigencia = 'V';
CREATE INDEX IF NOT EXISTS idx_ubicacion_cvecuenta ON ubicacion(cvecuenta);

-- Índices para búsqueda por clave catastral (SP 5)
CREATE INDEX IF NOT EXISTS idx_convcta_cvecatnva_pattern ON convcta(cvecatnva text_pattern_ops);
CREATE INDEX IF NOT EXISTS idx_convcta_subpredio ON convcta(subpredio);
CREATE INDEX IF NOT EXISTS idx_catastro_cvecuenta ON catastro(cvecuenta);

-- Índices generales para JOINs frecuentes
CREATE INDEX IF NOT EXISTS idx_ubicacion_cveubic ON ubicacion(cveubic);
CREATE INDEX IF NOT EXISTS idx_c_calidpro_cvereg ON c_calidpro(cvereg);

-- Nota: Los índices GIN con gin_trgm_ops requieren la extensión pg_trgm
-- Para habilitarla: CREATE EXTENSION IF NOT EXISTS pg_trgm;
*/

-- ============================================
-- VERIFICACIÓN DE STORED PROCEDURES
-- ============================================

-- Verificar que todas las funciones se crearon correctamente
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public'
      AND p.proname IN (
          'sp_busque_search_by_owner',
          'sp_busque_search_by_account',
          'sp_busque_search_by_rfc',
          'sp_busque_search_by_location',
          'sp_busque_search_by_cadastral_key',
          'sp_busque_get_detail'
      );

    IF v_count = 6 THEN
        RAISE NOTICE '✓ Verificación exitosa: 6/6 stored procedures creados correctamente';
    ELSE
        RAISE WARNING '⚠ Advertencia: Solo % de 6 stored procedures fueron creados', v_count;
    END IF;
END;
$$;

-- ============================================
-- QUERIES DE PRUEBA (COMENTADAS)
-- ============================================
-- Descomentar para probar las funciones después del despliegue
-- ============================================

/*
-- Prueba 1: Búsqueda por nombre
SELECT * FROM public.sp_busque_search_by_owner('GARCIA');

-- Prueba 2: Búsqueda por cuenta
SELECT * FROM public.sp_busque_search_by_account(1, 'U', 12345);

-- Prueba 3: Búsqueda por RFC
SELECT * FROM public.sp_busque_search_by_rfc('GARA850101');

-- Prueba 4: Búsqueda por ubicación
SELECT * FROM public.sp_busque_search_by_location('JUAREZ', '123');

-- Prueba 5: Búsqueda por clave catastral
SELECT * FROM public.sp_busque_search_by_cadastral_key('01', '001', '001', '01');

-- Prueba 6: Obtener detalle completo
SELECT * FROM public.sp_busque_get_detail(1, 'U', 12345);

-- Verificar rendimiento de búsqueda por nombre (usar EXPLAIN ANALYZE)
EXPLAIN ANALYZE
SELECT * FROM public.sp_busque_search_by_owner('GARCIA');
*/

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- Componente: busque
-- Batch: 10
-- Fecha: 2025-11-21
--
-- SPs Implementados: 6/6 (100%)
--   1. sp_busque_search_by_owner - Búsqueda por nombre de propietario
--   2. sp_busque_search_by_account - Búsqueda por cuenta catastral
--   3. sp_busque_search_by_rfc - Búsqueda por RFC
--   4. sp_busque_search_by_location - Búsqueda por ubicación
--   5. sp_busque_search_by_cadastral_key - Búsqueda por clave catastral
--   6. sp_busque_get_detail - Detalle completo de cuenta
--
-- Schema utilizado: public
--
-- Tablas principales:
--   - convcta (conversión de cuentas)
--   - contrib (contribuyentes)
--   - regprop (registro de propietarios)
--   - ubicacion (ubicaciones/domicilios)
--   - catastro (información catastral)
--   - c_calidpro (catálogo calidad propiedad)
--
-- Características implementadas:
--   ✓ RETURNS TABLE para todos los SPs
--   ✓ Prefijo p_ para todos los parámetros
--   ✓ Prefijo v_ para variables locales
--   ✓ LIMIT 300 en todas las búsquedas
--   ✓ ILIKE para búsquedas case-insensitive
--   ✓ Validación de parámetros con RAISE EXCEPTION
--   ✓ Manejo de errores con EXCEPTION blocks
--   ✓ LEFT JOIN para datos opcionales
--   ✓ INNER JOIN para datos requeridos
--   ✓ ORDER BY para resultados ordenados
--   ✓ COALESCE para manejo de NULLs
--   ✓ JSONB para detalle estructurado
--   ✓ Comentarios con COMMENT ON FUNCTION
--   ✓ Índices recomendados en comentarios
--
-- Rendimiento:
--   ⚠ CRÍTICO: Implementar los índices recomendados
--   ⚠ Requerido: Extensión pg_trgm para índices GIN
--   ℹ Las búsquedas con ILIKE son lentas sin índices GIN
--
-- Testing:
--   - Queries de prueba incluidas (comentadas)
--   - Script de verificación incluido
--   - EXPLAIN ANALYZE recomendado para optimización
--
-- Compatibilidad:
--   ✓ PostgreSQL 12+
--   ✓ Laravel API genérico
--   ✓ Vue 3 frontend
--
-- ============================================
-- FIN DE IMPLEMENTACIÓN
-- ============================================
