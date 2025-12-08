-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: comun
-- ============================================
\c padron_licencias;
SET search_path TO comun, public;

-- ============================================
-- STORED PROCEDURES PARA SISTEMA DE CARGA CATASTRAL
-- Convención: SP_CARGA_XXX
-- Implementado: 2025-11-21
-- Tablas: convcta, catastro, ubicacion, contrib, condominio, avaluos, construc
-- Módulo: CARGA - Gestión completa de predios (Batch 10)
-- Total SPs: 7
-- ============================================

-- ============================================
-- SP 1/7: sp_get_predio_by_clave_catastral
-- Tipo: Query
-- Descripción: Obtiene los datos completos del predio por clave catastral y subpredio
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_predio_by_clave_catastral(
    p_cvecatnva VARCHAR,
    p_subpredio INTEGER
)
RETURNS TABLE(
    cvecatnva VARCHAR,
    subpredio INTEGER,
    cuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    propietario TEXT,
    ubicacion TEXT,
    colonia VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC,
    cvecuenta INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros
    IF p_cvecatnva IS NULL OR TRIM(p_cvecatnva) = '' THEN
        RAISE EXCEPTION 'La clave catastral es requerida';
    END IF;

    IF p_subpredio IS NULL THEN
        RAISE EXCEPTION 'El subpredio es requerido';
    END IF;

    RETURN QUERY
    SELECT
        c.cvecatnva,
        c.subpredio,
        c.cuenta,
        c.recaud,
        c.urbrus,
        COALESCE(
            TRIM(CONCAT_WS(' ',
                NULLIF(TRIM(p.paterno), ''),
                NULLIF(TRIM(p.materno), ''),
                NULLIF(TRIM(p.nombres), '')
            )),
            'SIN PROPIETARIO'
        )::TEXT AS propietario,
        COALESCE(u.calle, 'SIN UBICACIÓN')::TEXT AS ubicacion,
        COALESCE(u.colonia, '') AS colonia,
        COALESCE(u.noexterior, '') AS noexterior,
        COALESCE(u.interior, '') AS interior,
        COALESCE(a.supterr, 0) AS supterr,
        COALESCE(a.supconst, 0) AS supconst,
        COALESCE(a.valorterr, 0) AS valorterr,
        COALESCE(a.valorconst, 0) AS valorconst,
        COALESCE(a.valfiscal, 0) AS valfiscal,
        c.cvecuenta
    FROM public.convcta c
    LEFT JOIN public.catastro a ON a.cvecuenta = c.cvecuenta
    LEFT JOIN public.ubicacion u ON u.cvecuenta = c.cvecuenta AND u.vigencia = 'V'
    LEFT JOIN LATERAL (
        SELECT
            paterno,
            materno,
            nombres
        FROM public.contrib
        WHERE cvecuenta = c.cvecuenta
        ORDER BY encabeza DESC, cvecont DESC
        LIMIT 1
    ) p ON TRUE
    WHERE c.cvecatnva = p_cvecatnva
      AND c.subpredio = p_subpredio
      AND c.vigente = 'V';
END;
$$;

COMMENT ON FUNCTION comun.sp_get_predio_by_clave_catastral(VARCHAR, INTEGER) IS 'Obtiene datos completos del predio por clave catastral y subpredio';

-- ============================================
-- SP 2/7: sp_get_predio_by_cuenta
-- Tipo: Query
-- Descripción: Obtiene los datos completos del predio por cuenta (recaud, urbrus, cuenta)
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_predio_by_cuenta(
    p_recaud INTEGER,
    p_urbrus VARCHAR,
    p_cuenta INTEGER
)
RETURNS TABLE(
    cvecatnva VARCHAR,
    subpredio INTEGER,
    cuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    propietario TEXT,
    ubicacion TEXT,
    colonia VARCHAR,
    noexterior VARCHAR,
    interior VARCHAR,
    supterr NUMERIC,
    supconst NUMERIC,
    valorterr NUMERIC,
    valorconst NUMERIC,
    valfiscal NUMERIC,
    cvecuenta INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros
    IF p_recaud IS NULL THEN
        RAISE EXCEPTION 'La recaudadora es requerida';
    END IF;

    IF p_urbrus IS NULL OR TRIM(p_urbrus) = '' THEN
        RAISE EXCEPTION 'El urbrus es requerido';
    END IF;

    IF p_cuenta IS NULL THEN
        RAISE EXCEPTION 'La cuenta es requerida';
    END IF;

    RETURN QUERY
    SELECT
        c.cvecatnva,
        c.subpredio,
        c.cuenta,
        c.recaud,
        c.urbrus,
        COALESCE(
            TRIM(CONCAT_WS(' ',
                NULLIF(TRIM(p.paterno), ''),
                NULLIF(TRIM(p.materno), ''),
                NULLIF(TRIM(p.nombres), '')
            )),
            'SIN PROPIETARIO'
        )::TEXT AS propietario,
        COALESCE(u.calle, 'SIN UBICACIÓN')::TEXT AS ubicacion,
        COALESCE(u.colonia, '') AS colonia,
        COALESCE(u.noexterior, '') AS noexterior,
        COALESCE(u.interior, '') AS interior,
        COALESCE(a.supterr, 0) AS supterr,
        COALESCE(a.supconst, 0) AS supconst,
        COALESCE(a.valorterr, 0) AS valorterr,
        COALESCE(a.valorconst, 0) AS valorconst,
        COALESCE(a.valfiscal, 0) AS valfiscal,
        c.cvecuenta
    FROM public.convcta c
    LEFT JOIN public.catastro a ON a.cvecuenta = c.cvecuenta
    LEFT JOIN public.ubicacion u ON u.cvecuenta = c.cvecuenta AND u.vigencia = 'V'
    LEFT JOIN LATERAL (
        SELECT
            paterno,
            materno,
            nombres
        FROM public.contrib
        WHERE cvecuenta = c.cvecuenta
        ORDER BY encabeza DESC, cvecont DESC
        LIMIT 1
    ) p ON TRUE
    WHERE c.recaud = p_recaud
      AND c.urbrus = p_urbrus
      AND c.cuenta = p_cuenta
      AND c.vigente = 'V';
END;
$$;

COMMENT ON FUNCTION comun.sp_get_predio_by_cuenta(INTEGER, VARCHAR, INTEGER) IS 'Obtiene datos completos del predio por cuenta catastral';

-- ============================================
-- SP 3/7: sp_get_cartografia_predial
-- Tipo: Report
-- Descripción: Devuelve la información cartográfica asociada a un predio (simulación para integración GIS)
-- API Compatible: RETURNS JSON
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_cartografia_predial(p_cvecatnva VARCHAR)
RETURNS JSON
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSON;
    v_existe BOOLEAN;
    v_cuenta INTEGER;
    v_recaud INTEGER;
    v_urbrus VARCHAR;
    v_supterr NUMERIC;
    v_supconst NUMERIC;
BEGIN
    -- Validación de parámetros
    IF p_cvecatnva IS NULL OR TRIM(p_cvecatnva) = '' THEN
        RAISE EXCEPTION 'La clave catastral es requerida';
    END IF;

    -- Verificar si existe el predio
    SELECT EXISTS(
        SELECT 1
        FROM public.convcta
        WHERE cvecatnva = p_cvecatnva
          AND vigente = 'V'
    ) INTO v_existe;

    IF NOT v_existe THEN
        v_result := json_build_object(
            'cvecatnva', p_cvecatnva,
            'status', 'error',
            'message', 'Predio no encontrado o no vigente'
        );
        RETURN v_result;
    END IF;

    -- Obtener datos del predio
    SELECT
        c.cuenta,
        c.recaud,
        c.urbrus,
        COALESCE(a.supterr, 0),
        COALESCE(a.supconst, 0)
    INTO
        v_cuenta,
        v_recaud,
        v_urbrus,
        v_supterr,
        v_supconst
    FROM public.convcta c
    LEFT JOIN public.catastro a ON a.cvecuenta = c.cvecuenta
    WHERE c.cvecatnva = p_cvecatnva
      AND c.vigente = 'V'
    LIMIT 1;

    -- Construir respuesta cartográfica (simulada para integración con microservicio GIS)
    v_result := json_build_object(
        'cvecatnva', p_cvecatnva,
        'cuenta', v_cuenta,
        'recaud', v_recaud,
        'urbrus', v_urbrus,
        'supterr', v_supterr,
        'supconst', v_supconst,
        'layers', json_build_array(
            'predios',
            'construcciones',
            'calles',
            'numeros_oficiales',
            'manzanas',
            'sectores'
        ),
        'capabilities', json_build_object(
            'zoom', true,
            'print', true,
            'measure', true,
            'overlay', true
        ),
        'status', 'ok',
        'message', 'Cartografía generada correctamente',
        'timestamp', CURRENT_TIMESTAMP
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION comun.sp_get_cartografia_predial(VARCHAR) IS 'Devuelve información cartográfica del predio para integración GIS';

-- ============================================
-- SP 4/7: sp_get_numeros_oficiales
-- Tipo: Report
-- Descripción: Devuelve los números oficiales de una manzana
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_numeros_oficiales(p_cvemanz VARCHAR)
RETURNS TABLE(
    cvecatnva VARCHAR,
    numero_oficial TEXT,
    noexterior VARCHAR,
    interior VARCHAR,
    calle TEXT,
    colonia VARCHAR,
    cuenta INTEGER,
    recaud INTEGER,
    urbrus VARCHAR,
    vigencia VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros
    IF p_cvemanz IS NULL OR TRIM(p_cvemanz) = '' THEN
        RAISE EXCEPTION 'La clave de manzana es requerida';
    END IF;

    RETURN QUERY
    SELECT
        b.cvecatnva,
        CASE
            WHEN a.interior IS NULL OR TRIM(a.interior) = '' OR a.interior = '00000'
            THEN COALESCE(a.noexterior, 'S/N')
            ELSE COALESCE(a.noexterior, 'S/N') || '-' || a.interior
        END::TEXT AS numero_oficial,
        COALESCE(a.noexterior, '') AS noexterior,
        COALESCE(a.interior, '') AS interior,
        COALESCE(a.calle, 'SIN CALLE')::TEXT AS calle,
        COALESCE(a.colonia, '') AS colonia,
        b.cuenta,
        b.recaud,
        b.urbrus,
        COALESCE(a.vigencia, 'N') AS vigencia
    FROM public.ubicacion a
    INNER JOIN public.convcta b ON a.cvecuenta = b.cvecuenta
    WHERE b.cvecatnva LIKE p_cvemanz || '%'
      AND b.vigente = 'V'
      AND a.vigencia = 'V'
    ORDER BY
        b.cvecatnva,
        a.noexterior NULLS LAST,
        a.interior NULLS LAST;
END;
$$;

COMMENT ON FUNCTION comun.sp_get_numeros_oficiales(VARCHAR) IS 'Devuelve los números oficiales de predios en una manzana';

-- ============================================
-- SP 5/7: sp_get_condominio
-- Tipo: Query
-- Descripción: Devuelve los datos del condominio asociado a una clave catastral
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_condominio(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cvecond INTEGER,
    nombre VARCHAR,
    tipocond VARCHAR,
    numpred INTEGER,
    escritura INTEGER,
    idnotaria INTEGER,
    fecescrit DATE,
    cvecatnva VARCHAR,
    areacomun NUMERIC,
    status TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros
    IF p_cvecatnva IS NULL OR TRIM(p_cvecatnva) = '' THEN
        RAISE EXCEPTION 'La clave catastral es requerida';
    END IF;

    RETURN QUERY
    SELECT
        cd.cvecond,
        COALESCE(cd.nombre, 'SIN NOMBRE') AS nombre,
        COALESCE(cd.tipocond, '') AS tipocond,
        COALESCE(cd.numpred, 0) AS numpred,
        cd.escritura,
        cd.idnotaria,
        cd.fecescrit,
        cd.cvecatnva,
        COALESCE(cd.areacomun, 0) AS areacomun,
        CASE
            WHEN cd.cvecond IS NOT NULL THEN 'ACTIVO'
            ELSE 'NO ENCONTRADO'
        END::TEXT AS status
    FROM public.condominio cd
    WHERE cd.cvecatnva = p_cvecatnva;

    -- Si no hay resultados, retornar un registro vacío indicando que no existe
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            NULL::INTEGER AS cvecond,
            'NO ES CONDOMINIO'::VARCHAR AS nombre,
            ''::VARCHAR AS tipocond,
            0::INTEGER AS numpred,
            NULL::INTEGER AS escritura,
            NULL::INTEGER AS idnotaria,
            NULL::DATE AS fecescrit,
            p_cvecatnva::VARCHAR AS cvecatnva,
            0::NUMERIC AS areacomun,
            'NO ENCONTRADO'::TEXT AS status;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_get_condominio(VARCHAR) IS 'Devuelve datos del condominio por clave catastral';

-- ============================================
-- SP 6/7: sp_get_avaluo
-- Tipo: Report
-- Descripción: Devuelve los datos de avalúo para una clave catastral
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_avaluo(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cveavaluo INTEGER,
    cvecatnva VARCHAR,
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
    feccap DATE,
    vigente VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros
    IF p_cvecatnva IS NULL OR TRIM(p_cvecatnva) = '' THEN
        RAISE EXCEPTION 'La clave catastral es requerida';
    END IF;

    RETURN QUERY
    SELECT
        av.cveavaluo,
        av.cvecatnva,
        COALESCE(av.supterr, 0) AS supterr,
        COALESCE(av.supconst, 0) AS supconst,
        COALESCE(av.valorterr, 0) AS valorterr,
        COALESCE(av.valorconst, 0) AS valorconst,
        COALESCE(av.valfiscal, 0) AS valfiscal,
        COALESCE(av.perimetro, 0) AS perimetro,
        COALESCE(av.frente, 0) AS frente,
        COALESCE(av.profund, 0) AS profund,
        COALESCE(av.factor, 0) AS factor,
        COALESCE(av.valorunit, 0) AS valorunit,
        COALESCE(av.indiviso, 0) AS indiviso,
        COALESCE(av.frentedis, 0) AS frentedis,
        COALESCE(av.factorajus, 0) AS factorajus,
        av.feccap,
        COALESCE(av.vigente, 'N') AS vigente
    FROM public.avaluos av
    WHERE av.cvecatnva = p_cvecatnva
    ORDER BY av.feccap DESC NULLS LAST, av.cveavaluo DESC;
END;
$$;

COMMENT ON FUNCTION comun.sp_get_avaluo(VARCHAR) IS 'Devuelve datos de avalúos por clave catastral';

-- ============================================
-- SP 7/7: sp_get_construcciones
-- Tipo: Report
-- Descripción: Devuelve las construcciones asociadas a una clave catastral
-- API Compatible: RETURNS TABLE
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_get_construcciones(p_cvecatnva VARCHAR)
RETURNS TABLE(
    cvebloque INTEGER,
    cveavaluo INTEGER,
    cveclasif INTEGER,
    estructura INTEGER,
    areaconst NUMERIC,
    importe NUMERIC,
    factorajus NUMERIC,
    vigente VARCHAR,
    descripcion VARCHAR,
    tipo_construccion TEXT,
    valor_unitario NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validación de parámetros
    IF p_cvecatnva IS NULL OR TRIM(p_cvecatnva) = '' THEN
        RAISE EXCEPTION 'La clave catastral es requerida';
    END IF;

    RETURN QUERY
    SELECT
        cn.cvebloque,
        cn.cveavaluo,
        cn.cveclasif,
        cn.estructura,
        COALESCE(cn.areaconst, 0) AS areaconst,
        COALESCE(cn.importe, 0) AS importe,
        COALESCE(cn.factorajus, 0) AS factorajus,
        COALESCE(cn.vigente, 'N') AS vigente,
        COALESCE(cn.descripcion, 'SIN DESCRIPCIÓN') AS descripcion,
        CASE
            WHEN cn.cveclasif IS NOT NULL THEN 'CLASIFICADA'
            ELSE 'SIN CLASIFICAR'
        END::TEXT AS tipo_construccion,
        CASE
            WHEN cn.areaconst > 0 THEN ROUND(cn.importe / cn.areaconst, 2)
            ELSE 0
        END::NUMERIC AS valor_unitario
    FROM public.construc cn
    WHERE cn.cvecatnva = p_cvecatnva
    ORDER BY cn.cvebloque, cn.vigente DESC;
END;
$$;

COMMENT ON FUNCTION comun.sp_get_construcciones(VARCHAR) IS 'Devuelve construcciones asociadas a una clave catastral';

-- ============================================
-- ÍNDICES RECOMENDADOS
-- ============================================

-- IMPORTANTE: Verificar si estos índices ya existen antes de crearlos
-- Para mejorar el rendimiento de las consultas

-- Índice para búsqueda por clave catastral y subpredio
-- CREATE INDEX IF NOT EXISTS idx_convcta_cvecatnva_subpredio ON public.convcta(cvecatnva, subpredio) WHERE vigente = 'V';

-- Índice para búsqueda por cuenta catastral
-- CREATE INDEX IF NOT EXISTS idx_convcta_recaud_urbrus_cuenta ON public.convcta(recaud, urbrus, cuenta) WHERE vigente = 'V';

-- Índice para relación con catastro
-- CREATE INDEX IF NOT EXISTS idx_catastro_cvecuenta ON public.catastro(cvecuenta);

-- Índice para ubicación vigente
-- CREATE INDEX IF NOT EXISTS idx_ubicacion_cvecuenta_vigente ON public.ubicacion(cvecuenta) WHERE vigencia = 'V';

-- Índice para contribuyentes encabezados
-- CREATE INDEX IF NOT EXISTS idx_contrib_cvecuenta_encabeza ON public.contrib(cvecuenta, encabeza DESC, cvecont DESC);

-- Índice para números oficiales por manzana
-- CREATE INDEX IF NOT EXISTS idx_convcta_cvecatnva_pattern ON public.convcta(cvecatnva varchar_pattern_ops) WHERE vigente = 'V';

-- Índice para condominios
-- CREATE INDEX IF NOT EXISTS idx_condominio_cvecatnva ON public.condominio(cvecatnva);

-- Índice para avalúos
-- CREATE INDEX IF NOT EXISTS idx_avaluos_cvecatnva_feccap ON public.avaluos(cvecatnva, feccap DESC);

-- Índice para construcciones
-- CREATE INDEX IF NOT EXISTS idx_construc_cvecatnva ON public.construc(cvecatnva);

-- ============================================
-- VERIFICACIÓN DE FUNCIONES IMPLEMENTADAS
-- ============================================

-- Verificar que todas las funciones se crearon correctamente
SELECT
    routine_name,
    routine_type,
    data_type as return_type
FROM information_schema.routines
WHERE routine_schema = 'comun'
  AND routine_name LIKE 'sp_get_%'
  AND routine_name IN (
    'sp_get_predio_by_clave_catastral',
    'sp_get_predio_by_cuenta',
    'sp_get_cartografia_predial',
    'sp_get_numeros_oficiales',
    'sp_get_condominio',
    'sp_get_avaluo',
    'sp_get_construcciones'
  )
ORDER BY routine_name;

-- ============================================
-- PRUEBAS DE FUNCIONES
-- ============================================

-- NOTA: Descomentar y ajustar con datos reales para probar

-- Prueba 1: Buscar predio por clave catastral
-- SELECT * FROM comun.sp_get_predio_by_clave_catastral('123456789012345678', 0);

-- Prueba 2: Buscar predio por cuenta
-- SELECT * FROM comun.sp_get_predio_by_cuenta(1, 'U', 12345);

-- Prueba 3: Obtener cartografía
-- SELECT * FROM comun.sp_get_cartografia_predial('123456789012345678');

-- Prueba 4: Obtener números oficiales de manzana
-- SELECT * FROM comun.sp_get_numeros_oficiales('12345678901234');

-- Prueba 5: Obtener datos de condominio
-- SELECT * FROM comun.sp_get_condominio('123456789012345678');

-- Prueba 6: Obtener avalúos
-- SELECT * FROM comun.sp_get_avaluo('123456789012345678');

-- Prueba 7: Obtener construcciones
-- SELECT * FROM comun.sp_get_construcciones('123456789012345678');

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================

/*
MÓDULO: CARGA - Gestión completa de predios
TOTAL SPs IMPLEMENTADOS: 7/7 (100%)

FUNCIONES QUERY (5):
  1. sp_get_predio_by_clave_catastral - Búsqueda por clave catastral y subpredio
  2. sp_get_predio_by_cuenta - Búsqueda por cuenta (recaud, urbrus, cuenta)
  3. sp_get_numeros_oficiales - Números oficiales por manzana
  4. sp_get_condominio - Datos de condominio
  5. sp_get_avaluo - Datos de avalúos

FUNCIONES REPORT (2):
  6. sp_get_cartografia_predial - Información cartográfica (integración GIS)
  7. sp_get_construcciones - Construcciones asociadas al predio

TABLAS PRINCIPALES:
  - convcta (conversión de cuentas)
  - catastro (datos catastrales)
  - ubicacion (direcciones)
  - contrib (propietarios)
  - condominio (condominios)
  - avaluos (avalúos)
  - construc (construcciones)

CARACTERÍSTICAS IMPLEMENTADAS:
  ✓ Validación de parámetros con RAISE EXCEPTION
  ✓ Uso de COALESCE para manejo robusto de NULLs
  ✓ Filtro vigente='V' para registros activos
  ✓ LATERAL JOINs para optimización
  ✓ Comentarios descriptivos en todas las funciones
  ✓ Índices recomendados para optimización
  ✓ Queries de verificación
  ✓ Queries de prueba comentadas
  ✓ Manejo de casos especiales (números oficiales, condominios inexistentes)
  ✓ Cálculos derivados (valor unitario en construcciones)

ESQUEMA: comun (compartido entre módulos)
LENGUAJE: plpgsql
COMPATIBLE CON: PostgreSQL 12+ / Laravel API / Vue 3

BATCH: 10/N
PRIORIDAD: Media
ESTADO: COMPLETADO ✓

Implementado por: Claude Code
Fecha: 2025-11-21
*/
