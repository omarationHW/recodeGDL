-- ============================================
-- STORED PROCEDURES IMPLEMENTADOS
-- Componente: consAnun400frm
-- Módulo: padron_licencias
-- Generado: 2025-11-20
-- Total SPs: 2
-- ============================================
--
-- DESCRIPCIÓN:
-- Consulta de anuncios publicitarios modelo 400 (datos históricos del AS/400)
-- Permite consultar información detallada de anuncios y sus pagos asociados
--
-- TABLAS UTILIZADAS:
-- - public.anuncio_400: Datos históricos de anuncios del AS/400
-- - public.pago_anun_400: Pagos asociados a anuncios del AS/400
--
-- CARACTERÍSTICAS:
-- - Consulta de datos históricos
-- - Información completa de anuncios
-- - Historial de pagos
-- - Validación de parámetros
-- - Manejo de excepciones
-- ============================================

-- ============================================
-- CONFIGURACIÓN DE BASE DE DATOS Y ESQUEMA
-- ============================================
-- \c padron_licencias;
SET search_path TO public;

-- ============================================
-- SP 1/2: sp_get_anuncio_400
-- Tipo: Consulta (READ)
-- Descripción: Obtiene todos los datos de un anuncio del AS/400 por número de anuncio
-- ============================================
-- Parámetros:
--   p_numanu: Número de anuncio a consultar
-- Retorna:
--   Registro completo del anuncio con todos sus campos
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_anuncio_400(
    p_numanu INTEGER
)
RETURNS TABLE (
    -- Campos de zona y fechas
    zona TEXT,
    nzona TEXT,
    nmza TEXT,
    fecalt DATE,
    feccam DATE,
    fecbaj DATE,

    -- Año 1 - Pagos y datos
    nuay1 TEXT,
    cvpa1 TEXT,
    fepa1 DATE,
    rein1 TEXT,
    recl1 TEXT,
    nuof1 TEXT,
    impe1 NUMERIC,
    imiv1 NUMERIC,
    pdpa1 NUMERIC,
    nuct1 TEXT,

    -- Año 2 - Pagos y datos
    nuay2 TEXT,
    cvpa2 TEXT,
    fepa2 DATE,
    rein2 TEXT,
    recl2 TEXT,
    nuof2 TEXT,
    impe2 NUMERIC,
    imiv2 NUMERIC,
    pdpa2 NUMERIC,
    nuct2 TEXT,

    -- Año 3 - Pagos y datos
    nuay3 TEXT,
    cvpa3 TEXT,
    fepa3 DATE,
    rein3 TEXT,
    recl3 TEXT,
    nuof3 TEXT,
    impe3 NUMERIC,
    imiv3 NUMERIC,
    pdpa3 NUMERIC,
    nuct3 TEXT,

    -- Totales y datos generales
    nuayt3 TEXT,
    reint3 TEXT,
    rctl TEXT,
    impet NUMERIC,
    imivt NUMERIC,
    cvemc TEXT,
    fut1 TEXT,
    fut2 TEXT,
    numlica TEXT,
    numanu INTEGER,

    -- Datos del establecimiento
    nomesta TEXT,
    rfc TEXT,
    numdili TEXT,
    ngrupo TEXT,
    lsector TEXT,
    ncolon TEXT,
    ncalle TEXT,
    lcalle TEXT,
    tipubic TEXT,
    nubic TEXT,
    nomcol TEXT,
    nomcall TEXT,
    noext TEXT,
    lext TEXT,
    nint TEXT,
    lint TEXT,
    nempre TEXT,
    nomcau TEXT,

    -- Datos del contribuyente
    crfc TEXT,
    cngrupo TEXT,
    clsector TEXT,
    cncolon TEXT,
    cncalle TEXT,
    clcalle TEXT,
    ctipubic TEXT,
    cnubic TEXT,
    cnomcol TEXT,
    cnomcall TEXT,
    cnext TEXT,
    clext TEXT,
    cnint TEXT,
    clint TEXT,

    -- Datos del anuncio
    tipanu TEXT,
    pmetr NUMERIC,
    smetr NUMERIC,
    angrupo TEXT,
    alsector TEXT,
    ancolon TEXT,
    ancalle TEXT,
    alcalle TEXT,
    anubic TEXT,
    anomcol TEXT,
    anomcall TEXT,
    anext TEXT,
    alext TEXT,
    anint TEXT,
    alint TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    -- ========================================
    -- VALIDACIÓN DE PARÁMETROS
    -- ========================================

    -- Validar que el número de anuncio sea válido
    IF p_numanu IS NULL THEN
        RAISE EXCEPTION 'ERROR: El número de anuncio es requerido'
            USING HINT = 'Debe proporcionar un número de anuncio válido',
                  ERRCODE = '22000';
    END IF;

    IF p_numanu <= 0 THEN
        RAISE EXCEPTION 'ERROR: El número de anuncio debe ser mayor a cero'
            USING HINT = 'Número proporcionado: %', p_numanu,
                  ERRCODE = '22000';
    END IF;

    -- ========================================
    -- VALIDACIÓN DE EXISTENCIA
    -- ========================================

    -- Verificar que existe el anuncio
    SELECT COUNT(*)
    INTO v_count
    FROM public.anuncio_400
    WHERE numanu = p_numanu;

    IF v_count = 0 THEN
        RAISE EXCEPTION 'ERROR: No se encontró el anuncio con número %', p_numanu
            USING HINT = 'Verifique que el número de anuncio sea correcto',
                  ERRCODE = '02000';
    END IF;

    -- ========================================
    -- CONSULTA PRINCIPAL
    -- ========================================

    RETURN QUERY
    SELECT
        a.zona,
        a.nzona,
        a.nmza,
        a.fecalt,
        a.feccam,
        a.fecbaj,

        -- Año 1
        a.nuay1,
        a.cvpa1,
        a.fepa1,
        a.rein1,
        a.recl1,
        a.nuof1,
        a.impe1,
        a.imiv1,
        a.pdpa1,
        a.nuct1,

        -- Año 2
        a.nuay2,
        a.cvpa2,
        a.fepa2,
        a.rein2,
        a.recl2,
        a.nuof2,
        a.impe2,
        a.imiv2,
        a.pdpa2,
        a.nuct2,

        -- Año 3
        a.nuay3,
        a.cvpa3,
        a.fepa3,
        a.rein3,
        a.recl3,
        a.nuof3,
        a.impe3,
        a.imiv3,
        a.pdpa3,
        a.nuct3,

        -- Totales
        a.nuayt3,
        a.reint3,
        a.rctl,
        a.impet,
        a.imivt,
        a.cvemc,
        a.fut1,
        a.fut2,
        a.numlica,
        a.numanu,

        -- Establecimiento
        a.nomesta,
        a.rfc,
        a.numdili,
        a.ngrupo,
        a.lsector,
        a.ncolon,
        a.ncalle,
        a.lcalle,
        a.tipubic,
        a.nubic,
        a.nomcol,
        a.nomcall,
        a.noext,
        a.lext,
        a.nint,
        a.lint,
        a.nempre,
        a.nomcau,

        -- Contribuyente
        a.crfc,
        a.cngrupo,
        a.clsector,
        a.cncolon,
        a.cncalle,
        a.clcalle,
        a.ctipubic,
        a.cnubic,
        a.cnomcol,
        a.cnomcall,
        a.cnext,
        a.clext,
        a.cnint,
        a.clint,

        -- Anuncio
        a.tipanu,
        a.pmetr,
        a.smetr,
        a.angrupo,
        a.alsector,
        a.ancolon,
        a.ancalle,
        a.alcalle,
        a.anubic,
        a.anomcol,
        a.anomcall,
        a.anext,
        a.alext,
        a.anint,
        a.alint
    FROM public.anuncio_400 a
    WHERE a.numanu = p_numanu;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR al consultar el anuncio 400: % - %', SQLSTATE, SQLERRM
            USING HINT = 'Verifique los datos y contacte al administrador si el problema persiste';
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_get_anuncio_400(INTEGER) IS
'Obtiene todos los datos de un anuncio del AS/400 por número de anuncio.
Incluye información completa de zona, pagos, establecimiento, contribuyente y características del anuncio.
Valida la existencia del anuncio antes de retornar los datos.';

-- ============================================
-- SP 2/2: sp_get_pagos_anun_400
-- Tipo: Consulta (READ)
-- Descripción: Obtiene todos los pagos asociados a un anuncio del AS/400
-- ============================================
-- Parámetros:
--   p_numanu: Número de anuncio del cual consultar los pagos
-- Retorna:
--   Conjunto de registros con los pagos del anuncio
-- ============================================

CREATE OR REPLACE FUNCTION public.sp_get_pagos_anun_400(
    p_numanu INTEGER
)
RETURNS TABLE (
    numanu INTEGER,
    periodo TEXT,
    fecha_pago DATE,
    importe NUMERIC,
    recargo NUMERIC,
    descuento NUMERIC,
    total NUMERIC,
    folio_pago TEXT,
    tipo_pago TEXT,
    referencia TEXT,
    observaciones TEXT,
    anio TEXT,
    mes TEXT,
    clave_pago TEXT,
    numero_oficio TEXT,
    numero_cuenta TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count_anuncio INTEGER;
    v_count_pagos INTEGER;
BEGIN
    -- ========================================
    -- VALIDACIÓN DE PARÁMETROS
    -- ========================================

    -- Validar que el número de anuncio sea válido
    IF p_numanu IS NULL THEN
        RAISE EXCEPTION 'ERROR: El número de anuncio es requerido'
            USING HINT = 'Debe proporcionar un número de anuncio válido',
                  ERRCODE = '22000';
    END IF;

    IF p_numanu <= 0 THEN
        RAISE EXCEPTION 'ERROR: El número de anuncio debe ser mayor a cero'
            USING HINT = 'Número proporcionado: %', p_numanu,
                  ERRCODE = '22000';
    END IF;

    -- ========================================
    -- VALIDACIÓN DE EXISTENCIA DEL ANUNCIO
    -- ========================================

    -- Verificar que existe el anuncio en la tabla principal
    SELECT COUNT(*)
    INTO v_count_anuncio
    FROM public.anuncio_400
    WHERE numanu = p_numanu;

    IF v_count_anuncio = 0 THEN
        RAISE EXCEPTION 'ERROR: No se encontró el anuncio con número %', p_numanu
            USING HINT = 'Verifique que el número de anuncio exista en el sistema',
                  ERRCODE = '02000';
    END IF;

    -- ========================================
    -- VERIFICAR EXISTENCIA DE PAGOS
    -- ========================================

    SELECT COUNT(*)
    INTO v_count_pagos
    FROM public.pago_anun_400
    WHERE numanu = p_numanu;

    -- Si no hay pagos, retornar conjunto vacío (no es error)
    IF v_count_pagos = 0 THEN
        RAISE NOTICE 'INFORMACIÓN: No se encontraron pagos para el anuncio %', p_numanu;
        RETURN;
    END IF;

    -- ========================================
    -- CONSULTA PRINCIPAL DE PAGOS
    -- ========================================

    RETURN QUERY
    SELECT
        p.numanu,
        p.periodo,
        p.fecha_pago,
        p.importe,
        p.recargo,
        p.descuento,
        p.total,
        p.folio_pago,
        p.tipo_pago,
        p.referencia,
        p.observaciones,
        p.anio,
        p.mes,
        p.clave_pago,
        p.numero_oficio,
        p.numero_cuenta
    FROM public.pago_anun_400 p
    WHERE p.numanu = p_numanu
    ORDER BY
        p.fecha_pago DESC,
        p.anio DESC,
        p.mes DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR al consultar los pagos del anuncio 400: % - %', SQLSTATE, SQLERRM
            USING HINT = 'Verifique los datos y contacte al administrador si el problema persiste';
END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION public.sp_get_pagos_anun_400(INTEGER) IS
'Obtiene todos los pagos asociados a un anuncio del AS/400 por número de anuncio.
Incluye información completa de cada pago: importes, recargos, descuentos, fechas y referencias.
Valida la existencia del anuncio antes de buscar los pagos.
Retorna los pagos ordenados por fecha descendente.';

-- ============================================
-- GRANTS Y PERMISOS
-- ============================================

-- Otorgar permisos de ejecución al rol de aplicación
-- GRANT EXECUTE ON FUNCTION public.sp_get_anuncio_400(INTEGER) TO app_padron_licencias;
-- GRANT EXECUTE ON FUNCTION public.sp_get_pagos_anun_400(INTEGER) TO app_padron_licencias;

-- ============================================
-- ÍNDICES RECOMENDADOS PARA OPTIMIZACIÓN
-- ============================================

-- Índice para búsqueda por número de anuncio
-- CREATE INDEX IF NOT EXISTS idx_anuncio_400_numanu ON public.anuncio_400(numanu);
-- CREATE INDEX IF NOT EXISTS idx_pago_anun_400_numanu ON public.pago_anun_400(numanu);

-- Índice para ordenamiento de pagos
-- CREATE INDEX IF NOT EXISTS idx_pago_anun_400_fecha ON public.pago_anun_400(numanu, fecha_pago DESC);

-- ============================================
-- RESUMEN DE IMPLEMENTACIÓN
-- ============================================
--
-- Total de SPs implementados: 2
--
-- 1. sp_get_anuncio_400
--    - Tipo: Consulta (READ)
--    - Schema: public
--    - Parámetros: p_numanu INTEGER
--    - Retorna: Registro completo del anuncio
--    - Validaciones: ✓ Parámetro requerido, ✓ Valor positivo, ✓ Existencia
--
-- 2. sp_get_pagos_anun_400
--    - Tipo: Consulta (READ)
--    - Schema: public
--    - Parámetros: p_numanu INTEGER
--    - Retorna: Conjunto de pagos del anuncio
--    - Validaciones: ✓ Parámetro requerido, ✓ Valor positivo, ✓ Existencia del anuncio
--
-- TABLAS UTILIZADAS:
-- - public.anuncio_400
-- - public.pago_anun_400
--
-- CARACTERÍSTICAS IMPLEMENTADAS:
-- ✓ Validación exhaustiva de parámetros
-- ✓ Verificación de existencia de registros
-- ✓ Manejo robusto de excepciones
-- ✓ Mensajes descriptivos de error
-- ✓ Ordenamiento de resultados
-- ✓ Comentarios SQL descriptivos
-- ✓ Logs informativos
-- ✓ Nomenclatura estándar (p_ para parámetros, v_ para variables)
-- ✓ Código documentado y mantenible
--
-- CASOS DE USO:
-- 1. Consulta de anuncios históricos del AS/400
-- 2. Revisión del historial de pagos de anuncios
-- 3. Auditoría de información migrada del AS/400
-- 4. Generación de reportes históricos
--
-- ============================================
-- FIN DE IMPLEMENTACIÓN
-- ============================================
