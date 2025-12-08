-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: public
-- ============================================
\c padron_licencias;
SET search_path TO public;

-- ============================================
-- STORED PROCEDURES PARA CARGA DE DATOS CATASTRALES
-- Convención: SP_CARGADATOS_XXX
-- Componente: CARGADATOSFRM (Batch 10)
-- Implementado: 2025-11-21
-- Tablas: ubicacion, contribuyente, regprop, avaluos, construc, usos_suelo, construc_carto, c_bloqcon
-- Módulo: Sistema de Carga Completa de Datos Catastrales
-- Total SPs: 5
-- Progreso: 62/95 componentes (65.3%)
-- ============================================

-- ============================================
-- SP 1/5: sp_get_cargadatos
-- Tipo: Catalog (JSON)
-- Descripción: Obtiene los datos principales de la cuenta catastral (ubicación, propietario, domicilio, usos de suelo)
-- Parámetros:
--   - p_cvecatnva: Clave catastral de la cuenta (formato: zona-manzana-predio)
-- Retorna: JSONB con todos los datos de la cuenta catastral
-- API Compatible: RETURNS JSONB
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_get_cargadatos(p_cvecatnva TEXT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_count INTEGER;
BEGIN
    -- Validación: verificar que existe la clave catastral
    SELECT COUNT(*) INTO v_count
    FROM ubicacion
    WHERE cvecatnva = p_cvecatnva;

    IF v_count = 0 THEN
        RAISE EXCEPTION 'Clave catastral % no encontrada', p_cvecatnva;
    END IF;

    -- Construir el objeto JSON con todos los datos principales
    SELECT jsonb_build_object(
        'cvecatnva', u.cvecatnva,
        -- Datos de ubicación
        'ubicacion', jsonb_build_object(
            'calle', COALESCE(u.calle, ''),
            'noexterior', COALESCE(u.noexterior, ''),
            'interior', COALESCE(u.interior, ''),
            'colonia', COALESCE(u.colonia, ''),
            'cp', COALESCE(u.codpos, ''),
            'cveubic', u.cveubic
        ),
        -- Datos del contribuyente/propietario
        'contribuyente', jsonb_build_object(
            'nombre_completo', COALESCE(c.nombre_completo, ''),
            'rfc', COALESCE(c.rfc, ''),
            'domicilio', COALESCE(c.domicilio, ''),
            'codpos', COALESCE(c.codpos, ''),
            'cvecont', c.cvecont
        ),
        -- Datos del registro de propiedad
        'regprop', jsonb_build_object(
            'poblacion', COALESCE(r.poblacion, ''),
            'encabeza', COALESCE(r.encabeza, ''),
            'porcentaje', COALESCE(r.porcentaje, 0),
            'cveregprop', r.cveregprop
        ),
        -- Datos de avalúos (último avalúo)
        'avaluo', jsonb_build_object(
            'observacion', COALESCE(a.observacion, ''),
            'supterr', COALESCE(a.supterr, 0),
            'supconst', COALESCE(a.supconst, 0),
            'valorterr', COALESCE(a.valorterr, 0),
            'valorconst', COALESCE(a.valorconst, 0),
            'valfiscal', COALESCE(a.valfiscal, 0),
            'feccap', a.feccap,
            'cveavaluo', a.cveavaluo
        ),
        -- Usos de suelo (array de objetos)
        'usos_suelo', COALESCE(
            (SELECT jsonb_agg(
                jsonb_build_object(
                    'uso', us.uso,
                    'descripcion', COALESCE(us.descripcion, ''),
                    'cveuso', us.cveuso
                )
            )
            FROM usos_suelo us
            WHERE us.cvecatnva = p_cvecatnva),
            '[]'::jsonb
        ),
        -- Metadata
        'metadata', jsonb_build_object(
            'fecha_consulta', CURRENT_TIMESTAMP,
            'tiene_avaluos', EXISTS(SELECT 1 FROM avaluos WHERE cvecatnva = p_cvecatnva),
            'tiene_construcciones', EXISTS(SELECT 1 FROM construc WHERE cvecatnva = p_cvecatnva),
            'tiene_usos', EXISTS(SELECT 1 FROM usos_suelo WHERE cvecatnva = p_cvecatnva)
        )
    ) INTO v_result
    FROM ubicacion u
    LEFT JOIN contribuyente c ON c.cvecatnva = u.cvecatnva
    LEFT JOIN regprop r ON r.cvecatnva = u.cvecatnva AND r.encabeza = 'S'
    LEFT JOIN LATERAL (
        SELECT * FROM avaluos av
        WHERE av.cvecatnva = u.cvecatnva
        ORDER BY av.feccap DESC
        LIMIT 1
    ) a ON true
    WHERE u.cvecatnva = p_cvecatnva
    LIMIT 1;

    RETURN COALESCE(v_result, '{}'::jsonb);

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener datos catastrales: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION public.sp_get_cargadatos(TEXT) IS
'Obtiene todos los datos principales de una cuenta catastral en formato JSONB (ubicación, contribuyente, avalúos, usos de suelo)';

-- Índices recomendados:
-- CREATE INDEX IF NOT EXISTS idx_ubicacion_cvecatnva ON ubicacion(cvecatnva);
-- CREATE INDEX IF NOT EXISTS idx_contribuyente_cvecatnva ON contribuyente(cvecatnva);
-- CREATE INDEX IF NOT EXISTS idx_regprop_cvecatnva_encabeza ON regprop(cvecatnva, encabeza);
-- CREATE INDEX IF NOT EXISTS idx_avaluos_cvecatnva_feccap ON avaluos(cvecatnva, feccap DESC);
-- CREATE INDEX IF NOT EXISTS idx_usos_suelo_cvecatnva ON usos_suelo(cvecatnva);

-- ============================================
-- SP 2/5: sp_get_avaluos
-- Tipo: Catalog (TABLE)
-- Descripción: Obtiene todos los avalúos de una cuenta catastral y subpredio
-- Parámetros:
--   - p_cvecatnva: Clave catastral de la cuenta
--   - p_subpredio: Número de subpredio (0 para todos los subpredios)
-- Retorna: Tabla con todos los avalúos ordenados por fecha descendente
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_get_avaluos(
    p_cvecatnva TEXT,
    p_subpredio INTEGER DEFAULT 0
)
RETURNS TABLE(
    cveavaluo INTEGER,
    cvecatnva TEXT,
    subpredio SMALLINT,
    supterr NUMERIC(12,2),
    supconst NUMERIC(12,2),
    valorterr NUMERIC(15,2),
    valorconst NUMERIC(15,2),
    valfiscal NUMERIC(15,2),
    feccap DATE,
    observacion TEXT,
    axovig SMALLINT,
    anovaluo SMALLINT,
    cvetipo SMALLINT,
    vigente TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validación: verificar que existe la clave catastral
    SELECT COUNT(*) INTO v_count
    FROM ubicacion
    WHERE cvecatnva = p_cvecatnva;

    IF v_count = 0 THEN
        RAISE EXCEPTION 'Clave catastral % no encontrada', p_cvecatnva;
    END IF;

    -- Retornar todos los avalúos filtrados por subpredio
    RETURN QUERY
    SELECT
        a.cveavaluo,
        a.cvecatnva,
        a.subpredio,
        COALESCE(a.supterr, 0)::NUMERIC(12,2),
        COALESCE(a.supconst, 0)::NUMERIC(12,2),
        COALESCE(a.valorterr, 0)::NUMERIC(15,2),
        COALESCE(a.valorconst, 0)::NUMERIC(15,2),
        COALESCE(a.valfiscal, 0)::NUMERIC(15,2),
        a.feccap,
        COALESCE(a.observacion, '')::TEXT,
        a.axovig,
        a.anovaluo,
        a.cvetipo,
        COALESCE(a.vigente, 'V')::TEXT
    FROM avaluos a
    WHERE a.cvecatnva = p_cvecatnva
      AND (p_subpredio = 0 OR a.subpredio = p_subpredio)
    ORDER BY a.feccap DESC, a.cveavaluo DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener avalúos: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION public.sp_get_avaluos(TEXT, INTEGER) IS
'Obtiene todos los avalúos de una cuenta catastral, opcionalmente filtrados por subpredio';

-- Índices recomendados:
-- CREATE INDEX IF NOT EXISTS idx_avaluos_cvecatnva_subpredio ON avaluos(cvecatnva, subpredio);
-- CREATE INDEX IF NOT EXISTS idx_avaluos_feccap ON avaluos(feccap DESC);

-- ============================================
-- SP 3/5: sp_get_construcciones
-- Tipo: Catalog (TABLE)
-- Descripción: Obtiene las construcciones asociadas a un avalúo con su clasificación
-- Parámetros:
--   - p_cveavaluo: Clave del avalúo
-- Retorna: Tabla con todas las construcciones del avalúo
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_get_construcciones(p_cveavaluo INTEGER)
RETURNS TABLE(
    cveconstruc INTEGER,
    cvebloque INTEGER,
    cveclasif INTEGER,
    descripcion TEXT,
    areaconst NUMERIC(10,2),
    importe NUMERIC(15,2),
    numpisos SMALLINT,
    estructura TEXT,
    factorajus NUMERIC(5,4),
    axovig SMALLINT,
    cvetipo SMALLINT,
    nivelcons SMALLINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validación: verificar que existe el avalúo
    SELECT COUNT(*) INTO v_count
    FROM avaluos
    WHERE cveavaluo = p_cveavaluo;

    IF v_count = 0 THEN
        RAISE EXCEPTION 'Avalúo % no encontrado', p_cveavaluo;
    END IF;

    -- Retornar todas las construcciones con su clasificación
    RETURN QUERY
    SELECT
        a.cveconstruc,
        a.cvebloque,
        a.cveclasif,
        COALESCE(b.descripcion, 'SIN CLASIFICACIÓN')::TEXT,
        COALESCE(a.areaconst, 0)::NUMERIC(10,2),
        COALESCE(a.importe, 0)::NUMERIC(15,2),
        COALESCE(a.numpisos, 0)::SMALLINT,
        COALESCE(a.estructura, '')::TEXT,
        COALESCE(a.factorajus, 1.0)::NUMERIC(5,4),
        a.axovig,
        a.cvetipo,
        COALESCE(a.nivelcons, 0)::SMALLINT
    FROM construc a
    LEFT JOIN c_bloqcon b ON b.axovig = a.axovig AND b.cveclasif = a.cveclasif
    WHERE a.cveavaluo = p_cveavaluo
    ORDER BY a.cvebloque, a.cveclasif;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener construcciones: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION public.sp_get_construcciones(INTEGER) IS
'Obtiene todas las construcciones de un avalúo con su clasificación y características';

-- Índices recomendados:
-- CREATE INDEX IF NOT EXISTS idx_construc_cveavaluo ON construc(cveavaluo);
-- CREATE INDEX IF NOT EXISTS idx_c_bloqcon_axovig_cveclasif ON c_bloqcon(axovig, cveclasif);

-- ============================================
-- SP 4/5: sp_get_area_carto
-- Tipo: Catalog (TABLE)
-- Descripción: Obtiene el área total de construcción cartográfica vigente para una clave catastral
-- Parámetros:
--   - p_cvecatnva: Clave catastral de la cuenta
-- Retorna: Suma del área de construcción cartográfica vigente
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_get_area_carto(p_cvecatnva TEXT)
RETURNS TABLE(
    supconst NUMERIC(12,2),
    total_construcciones INTEGER,
    cvecatnva TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- Validación: verificar que existe la clave catastral
    SELECT COUNT(*) INTO v_count
    FROM ubicacion
    WHERE cvecatnva = p_cvecatnva;

    IF v_count = 0 THEN
        RAISE EXCEPTION 'Clave catastral % no encontrada', p_cvecatnva;
    END IF;

    -- Retornar la suma del área de construcción cartográfica vigente
    RETURN QUERY
    SELECT
        COALESCE(SUM(cc.areaconst), 0)::NUMERIC(12,2) AS supconst,
        COUNT(*)::INTEGER AS total_construcciones,
        p_cvecatnva AS cvecatnva
    FROM construc_carto cc
    WHERE cc.cvecatnva = p_cvecatnva
      AND cc.vigente = 'V';

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al obtener área cartográfica: %', SQLERRM;
END;
$$;

COMMENT ON FUNCTION public.sp_get_area_carto(TEXT) IS
'Obtiene el área total de construcción cartográfica vigente de una cuenta catastral';

-- Índices recomendados:
-- CREATE INDEX IF NOT EXISTS idx_construc_carto_cvecatnva_vigente ON construc_carto(cvecatnva, vigente);

-- ============================================
-- SP 5/5: sp_save_cargadatos
-- Tipo: CRUD (UPDATE)
-- Descripción: Guarda o actualiza los datos principales de la cuenta catastral (contribuyente, ubicación)
-- Parámetros:
--   - p_cvecatnva: Clave catastral de la cuenta
--   - p_data: Objeto JSONB con los datos a actualizar
-- Retorna: JSONB con el resultado de la operación
-- API Compatible: RETURNS JSONB
-- --------------------------------------------

CREATE OR REPLACE FUNCTION public.sp_save_cargadatos(
    p_cvecatnva TEXT,
    p_data JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_updated_contrib BOOLEAN := false;
    v_updated_ubicacion BOOLEAN := false;
    v_count INTEGER;
    v_cvecont INTEGER;
BEGIN
    -- Validación: verificar que existe la clave catastral
    SELECT COUNT(*) INTO v_count
    FROM ubicacion
    WHERE cvecatnva = p_cvecatnva;

    IF v_count = 0 THEN
        RAISE EXCEPTION 'Clave catastral % no encontrada', p_cvecatnva;
    END IF;

    -- Validación: verificar que p_data es un objeto válido
    IF p_data IS NULL OR jsonb_typeof(p_data) != 'object' THEN
        RAISE EXCEPTION 'El parámetro p_data debe ser un objeto JSONB válido';
    END IF;

    -- Obtener el cvecont para actualizar contribuyente
    SELECT c.cvecont INTO v_cvecont
    FROM contribuyente c
    WHERE c.cvecatnva = p_cvecatnva
    LIMIT 1;

    -- Actualizar datos del contribuyente si existen en p_data
    IF v_cvecont IS NOT NULL THEN
        UPDATE contribuyente
        SET
            nombre_completo = COALESCE(p_data->>'nombre_completo', nombre_completo),
            rfc = COALESCE(p_data->>'rfc', rfc),
            domicilio = COALESCE(p_data->>'domicilio', domicilio),
            codpos = COALESCE(p_data->>'codpos', codpos),
            calle = COALESCE(p_data->>'calle_contrib', calle),
            noexterior = COALESCE(p_data->>'noexterior_contrib', noexterior),
            interior = COALESCE(p_data->>'interior_contrib', interior)
        WHERE cvecont = v_cvecont
          AND cvecatnva = p_cvecatnva;

        GET DIAGNOSTICS v_count = ROW_COUNT;
        v_updated_contrib := (v_count > 0);
    END IF;

    -- Actualizar datos de ubicación si existen en p_data
    UPDATE ubicacion
    SET
        calle = COALESCE(p_data->>'calle_ubica', calle),
        noexterior = COALESCE(p_data->>'noexterior_ubica', noexterior),
        interior = COALESCE(p_data->>'interior_ubica', interior),
        colonia = COALESCE(p_data->>'colonia', colonia),
        codpos = COALESCE(p_data->>'cp', codpos)
    WHERE cvecatnva = p_cvecatnva;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    v_updated_ubicacion := (v_count > 0);

    -- Construir el resultado
    v_result := jsonb_build_object(
        'success', true,
        'cvecatnva', p_cvecatnva,
        'updated_contrib', v_updated_contrib,
        'updated_ubicacion', v_updated_ubicacion,
        'mensaje', 'Datos actualizados correctamente',
        'timestamp', CURRENT_TIMESTAMP
    );

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', SQLERRM,
            'cvecatnva', p_cvecatnva,
            'timestamp', CURRENT_TIMESTAMP
        );
END;
$$;

COMMENT ON FUNCTION public.sp_save_cargadatos(TEXT, JSONB) IS
'Actualiza los datos principales de una cuenta catastral (contribuyente y ubicación)';

-- Índices recomendados:
-- CREATE INDEX IF NOT EXISTS idx_contribuyente_cvecatnva ON contribuyente(cvecatnva);
-- CREATE INDEX IF NOT EXISTS idx_ubicacion_cvecatnva ON ubicacion(cvecatnva);

-- ============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- ============================================

DO $$
DECLARE
    v_function_count INTEGER;
    v_expected_count INTEGER := 5;
BEGIN
    -- Contar funciones creadas
    SELECT COUNT(*) INTO v_function_count
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
    AND p.proname IN (
        'sp_get_cargadatos',
        'sp_get_avaluos',
        'sp_get_construcciones',
        'sp_get_area_carto',
        'sp_save_cargadatos'
    );

    RAISE NOTICE '============================================';
    RAISE NOTICE 'VERIFICACIÓN DE INSTALACIÓN - CARGADATOSFRM';
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Funciones esperadas: %', v_expected_count;
    RAISE NOTICE 'Funciones instaladas: %', v_function_count;

    IF v_function_count = v_expected_count THEN
        RAISE NOTICE 'Estado: ✓ TODAS LAS FUNCIONES INSTALADAS CORRECTAMENTE';
    ELSE
        RAISE WARNING 'Estado: ✗ FALTAN % FUNCIONES', (v_expected_count - v_function_count);
    END IF;

    RAISE NOTICE '============================================';
END $$;

-- ============================================
-- QUERIES DE VERIFICACIÓN Y TESTING
-- ============================================

-- Test 1: Verificar estructura de sp_get_cargadatos
-- SELECT public.sp_get_cargadatos('001-001-001');

-- Test 2: Verificar avalúos de una cuenta
-- SELECT * FROM public.sp_get_avaluos('001-001-001', 0);

-- Test 3: Verificar construcciones de un avalúo específico
-- SELECT * FROM public.sp_get_construcciones(1);

-- Test 4: Verificar área cartográfica
-- SELECT * FROM public.sp_get_area_carto('001-001-001');

-- Test 5: Probar actualización de datos
-- SELECT public.sp_save_cargadatos('001-001-001', '{"nombre_completo": "JUAN PEREZ", "rfc": "JUAP800101XXX"}'::jsonb);

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
-- Componente: CARGADATOSFRM (Batch 10)
-- Total SPs implementados: 5/5 (100%)
-- Schema: public
-- Fecha: 2025-11-21
-- Progreso general: 62/95 → 63/95 componentes (66.3%)
--
-- SPs implementados:
-- 1. sp_get_cargadatos      - JSONB - Datos completos catastrales
-- 2. sp_get_avaluos         - TABLE - Lista de avalúos
-- 3. sp_get_construcciones  - TABLE - Construcciones por avalúo
-- 4. sp_get_area_carto      - TABLE - Área cartográfica total
-- 5. sp_save_cargadatos     - JSONB - Actualización de datos
--
-- Características implementadas:
-- ✓ Uso de JSONB (no JSON) para mejor performance
-- ✓ Funciones (FUNCTION) no procedimientos
-- ✓ Prefijo p_ para parámetros
-- ✓ Prefijo v_ para variables
-- ✓ Manejo robusto de NULL con COALESCE
-- ✓ Validaciones de existencia
-- ✓ Manejo de excepciones
-- ✓ Comentarios descriptivos
-- ✓ Índices recomendados
-- ✓ Queries de verificación
-- ✓ Datos anidados con jsonb_agg() y jsonb_build_object()
-- ============================================
