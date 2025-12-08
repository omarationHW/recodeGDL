-- ============================================
-- CONFIGURACIÓN BASE DE DATOS: padron_licencias
-- ESQUEMA: comun
-- ============================================
\c padron_licencias;
SET search_path TO comun, public;

-- ============================================
-- STORED PROCEDURES PARA IMPRESIÓN DE LICENCIAS REGLAMENTADAS
-- Convención: sp_imp_licencia_reglamentada_*
-- Implementado: 2025-11-20
-- Tablas: comun.licencias, public.licencias, public.c_giros, public.bloqueo,
--         public.convcta, public.anuncios, public.detsal_lic
-- Módulo: IMPLICENCIAREGLAMENTADAFRM - Impresión de licencias reglamentadas
-- ============================================

-- ============================================
-- TABLA TEMPORAL PARA ADEUDOS DE LICENCIA
-- ============================================

-- Tabla temporal para almacenar adeudos calculados de licencias
CREATE TABLE IF NOT EXISTS public.tmp_adeudolic (
    id_registro SERIAL PRIMARY KEY,
    id_licencia INTEGER NOT NULL,
    numero VARCHAR(50),
    texto VARCHAR(255),
    ctaapl VARCHAR(20),
    importe NUMERIC(12,2) DEFAULT 0.00,
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índice para optimización de consultas
CREATE INDEX IF NOT EXISTS idx_tmp_adeudolic_licencia ON public.tmp_adeudolic(id_licencia);

-- ============================================
-- SP 1/4: sp_imp_licencia_reglamentada_get
-- Tipo: Query
-- Descripción: Obtiene los datos completos de una licencia reglamentada
--              Incluye información del giro, ubicación y clasificación
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_imp_licencia_reglamentada_get(
    p_numero_licencia VARCHAR(100) DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL
)
RETURNS TABLE(
    -- Datos de la licencia
    id_licencia INTEGER,
    numero_licencia INTEGER,
    folio VARCHAR(100),
    recaud VARCHAR(100),
    propietario VARCHAR(255),
    razon_social VARCHAR(255),
    rfc VARCHAR(20),
    curp VARCHAR(30),
    actividad VARCHAR(255),
    -- Datos de ubicación
    ubicacion TEXT,
    cvecalle INTEGER,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR(5),
    numint_ubic INTEGER,
    letraint_ubic VARCHAR(5),
    colonia VARCHAR(255),
    codigo_postal VARCHAR(10),
    -- Datos de zona y superficie
    zona VARCHAR(50),
    subzona VARCHAR(50),
    sup_autorizada NUMERIC(10,2),
    num_cajones INTEGER,
    aforo INTEGER,
    -- Datos del giro
    id_giro INTEGER,
    giro_descripcion VARCHAR(255),
    giro_clasificacion VARCHAR(5),
    giro_reglamentada VARCHAR(1),
    ctaaplic VARCHAR(20),
    -- Datos catastrales
    cvecatnva VARCHAR(50),
    subpredio VARCHAR(20),
    -- Datos administrativos
    espubic TEXT,
    fecha_consejo DATE,
    asiento INTEGER,
    bloqueado INTEGER,
    vigente VARCHAR(1),
    -- Datos calculados
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR(20),
    url_pdf TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id_licencia INTEGER;
BEGIN
    -- Validar parámetros
    IF p_id_licencia IS NULL AND p_numero_licencia IS NULL THEN
        RAISE EXCEPTION 'Debe proporcionar número de licencia o ID de licencia';
    END IF;

    -- Obtener ID de licencia si solo se proporcionó número
    IF p_id_licencia IS NULL THEN
        SELECT l.id_licencia INTO v_id_licencia
        FROM public.licencias l
        WHERE l.numero_licencia::VARCHAR = p_numero_licencia;

        IF v_id_licencia IS NULL THEN
            RAISE EXCEPTION 'Licencia no encontrada: %', p_numero_licencia;
        END IF;
    ELSE
        v_id_licencia := p_id_licencia;
    END IF;

    -- Retornar datos completos de la licencia
    RETURN QUERY
    SELECT
        l.id_licencia,
        l.numero_licencia,
        l.folio,
        COALESCE(l.recaud, 'NO ESPECIFICADA') as recaud,
        COALESCE(l.propietario, '') as propietario,
        COALESCE(l.razonsoc, l.propietario, '') as razon_social,
        COALESCE(l.rfc, '') as rfc,
        COALESCE(l.curp, '') as curp,
        COALESCE(g.descripcion, '') as actividad,
        -- Ubicación
        COALESCE(l.ubicacion, '') as ubicacion,
        COALESCE(l.cvecalle, 0) as cvecalle,
        COALESCE(l.numext_ubic, 0) as numext_ubic,
        COALESCE(l.letraext_ubic, '') as letraext_ubic,
        COALESCE(l.numint_ubic, 0) as numint_ubic,
        COALESCE(l.letraint_ubic, '') as letraint_ubic,
        COALESCE(l.colonia, '') as colonia,
        COALESCE(l.cp, '') as codigo_postal,
        -- Zona y superficie
        COALESCE(l.zona, '') as zona,
        COALESCE(l.subzona, '') as subzona,
        COALESCE(l.sup_autorizada, 0.00) as sup_autorizada,
        COALESCE(l.num_cajones, 0) as num_cajones,
        COALESCE(l.aforo, 0) as aforo,
        -- Giro
        COALESCE(l.id_giro, 0) as id_giro,
        COALESCE(g.descripcion, '') as giro_descripcion,
        COALESCE(g.clasificacion, '') as giro_clasificacion,
        COALESCE(g.reglamentada, 'N') as giro_reglamentada,
        COALESCE(g.ctaaplic, '') as ctaaplic,
        -- Catastrales
        COALESCE(c.cvecatnva, '') as cvecatnva,
        COALESCE(c.subpredio, '') as subpredio,
        -- Administrativos
        COALESCE(l.espubic, '') as espubic,
        l.fecha_consejo,
        COALESCE(l.asiento, 0) as asiento,
        COALESCE(l.bloqueado, 0) as bloqueado,
        COALESCE(l.vigente, 'N') as vigente,
        -- Fechas
        l.fecalt as fecha_expedicion,
        l.fecven as fecha_vencimiento,
        CASE
            WHEN l.vigente = 'V' THEN 'VIGENTE'
            WHEN l.vigente = 'B' THEN 'BAJA'
            ELSE 'INACTIVA'
        END as estado,
        -- URL del PDF (dinámica)
        'http://sistema.gob.mx/licencias/pdf/' || l.numero_licencia || '.pdf' as url_pdf
    FROM public.licencias l
    LEFT JOIN public.c_giros g ON g.id_giro = l.id_giro
    LEFT JOIN public.convcta c ON c.cvecuenta = l.cvecuenta
    WHERE l.id_licencia = v_id_licencia;

    -- Si no se encontró la licencia, lanzar error
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Licencia no encontrada con ID: %', v_id_licencia;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_imp_licencia_reglamentada_get(VARCHAR, INTEGER) IS
'Obtiene datos completos de una licencia reglamentada para impresión - Incluye giro, ubicación y clasificación';

-- ============================================
-- SP 2/4: sp_imp_licencia_reglamentada_check_bloqueada
-- Tipo: Validation
-- Descripción: Verifica si la licencia está bloqueada para impresión
--              Retorna tipo de bloqueo, motivo y fecha
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_imp_licencia_reglamentada_check_bloqueada(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    esta_bloqueada BOOLEAN,
    tipo_bloqueo INTEGER,
    descripcion_bloqueo VARCHAR(255),
    motivo_bloqueo TEXT,
    fecha_bloqueo DATE,
    usuario_bloqueo VARCHAR(100),
    permite_impresion BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_bloqueado INTEGER;
    v_clasificacion VARCHAR(5);
BEGIN
    -- Validar parámetros
    IF p_id_licencia IS NULL THEN
        RAISE EXCEPTION 'ID de licencia es requerido';
    END IF;

    -- Obtener estado de bloqueo y clasificación del giro
    SELECT l.bloqueado, COALESCE(g.clasificacion, '')
    INTO v_bloqueado, v_clasificacion
    FROM public.licencias l
    LEFT JOIN public.c_giros g ON g.id_giro = l.id_giro
    WHERE l.id_licencia = p_id_licencia;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Licencia no encontrada: %', p_id_licencia;
    END IF;

    -- Si no está bloqueada, retornar resultado negativo
    IF v_bloqueado IS NULL OR v_bloqueado = 0 THEN
        RETURN QUERY
        SELECT
            FALSE as esta_bloqueada,
            0 as tipo_bloqueo,
            ''::VARCHAR(255) as descripcion_bloqueo,
            ''::TEXT as motivo_bloqueo,
            NULL::DATE as fecha_bloqueo,
            ''::VARCHAR(100) as usuario_bloqueo,
            TRUE as permite_impresion;
        RETURN;
    END IF;

    -- Si está bloqueada, obtener detalles del bloqueo más reciente
    RETURN QUERY
    SELECT
        TRUE as esta_bloqueada,
        b.bloqueado as tipo_bloqueo,
        COALESCE(tb.descripcion, 'BLOQUEO GENERAL') as descripcion_bloqueo,
        COALESCE(b.observa, '') as motivo_bloqueo,
        b.fecha_mov as fecha_bloqueo,
        COALESCE(b.capturista, '') as usuario_bloqueo,
        -- Solo permite impresión si clasificación es 'D' (reglamentada) y NO está bloqueada
        CASE
            WHEN v_clasificacion = 'D' AND v_bloqueado = 0 THEN TRUE
            ELSE FALSE
        END as permite_impresion
    FROM public.bloqueo b
    LEFT JOIN public.c_tipobloqueo tb ON tb.id = b.bloqueado
    WHERE b.id_licencia = p_id_licencia
      AND b.vigente = 'V'
    ORDER BY b.fecha_mov DESC
    LIMIT 1;

    -- Si no hay registros de bloqueo pero la licencia tiene bloqueado > 0
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            TRUE as esta_bloqueada,
            v_bloqueado as tipo_bloqueo,
            'BLOQUEO SIN DETALLE'::VARCHAR(255) as descripcion_bloqueo,
            'Sin información de bloqueo'::TEXT as motivo_bloqueo,
            NULL::DATE as fecha_bloqueo,
            ''::VARCHAR(100) as usuario_bloqueo,
            FALSE as permite_impresion;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_imp_licencia_reglamentada_check_bloqueada(INTEGER) IS
'Verifica si una licencia está bloqueada y permite impresión - Retorna detalles del bloqueo';

-- ============================================
-- SP 3/4: sp_imp_licencia_reglamentada_calcular_adeudo
-- Tipo: Processing
-- Descripción: Calcula el adeudo total de una licencia y sus anuncios
--              Llena la tabla temporal tmp_adeudolic con el detalle
--              Calcula recargos al 2% mensual
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_imp_licencia_reglamentada_calcular_adeudo(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    registros_insertados INTEGER,
    total_adeudo NUMERIC(12,2),
    mensaje VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER := 0;
    v_total NUMERIC(12,2) := 0.00;
    v_existe_licencia BOOLEAN;
BEGIN
    -- Validar parámetros
    IF p_id_licencia IS NULL THEN
        RAISE EXCEPTION 'ID de licencia es requerido';
    END IF;

    -- Verificar que existe la licencia
    SELECT EXISTS(
        SELECT 1 FROM public.licencias
        WHERE id_licencia = p_id_licencia AND vigente = 'V'
    ) INTO v_existe_licencia;

    IF NOT v_existe_licencia THEN
        RAISE EXCEPTION 'Licencia no encontrada o no vigente: %', p_id_licencia;
    END IF;

    -- Limpiar registros anteriores de esta licencia en la tabla temporal
    DELETE FROM public.tmp_adeudolic WHERE id_licencia = p_id_licencia;

    -- Insertar adeudos de la licencia principal
    INSERT INTO public.tmp_adeudolic (
        id_licencia, numero, texto, ctaapl, importe
    )
    SELECT
        l.id_licencia,
        g.descripcion as numero,
        'LICENCIA' as texto,
        COALESCE(g.ctaaplic, 'LIC') as ctaapl,
        COALESCE(s.saldo, 0.00) as importe
    FROM public.licencias l
    JOIN public.c_giros g ON g.id_giro = l.id_giro
    LEFT JOIN public.detsal_lic s ON s.id_licencia = l.id_licencia
        AND s.id_anuncio = 0
        AND s.cvepago = 0
    WHERE l.id_licencia = p_id_licencia
      AND l.vigente = 'V'
      AND COALESCE(s.saldo, 0) > 0;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    -- Insertar adeudos de anuncios asociados (si existen)
    INSERT INTO public.tmp_adeudolic (
        id_licencia, numero, texto, ctaapl, importe
    )
    SELECT
        a.id_licencia,
        g.descripcion as numero,
        'ANUNCIO - ' || COALESCE(a.num_anuncio::VARCHAR, a.id_anuncio::VARCHAR) as texto,
        COALESCE(g.ctaaplic, 'ANU') as ctaapl,
        COALESCE(s.saldo, 0.00) as importe
    FROM public.anuncios a
    JOIN public.c_giros g ON g.id_giro = a.id_giro
    LEFT JOIN public.detsal_lic s ON s.id_anuncio = a.id_anuncio
        AND s.cvepago = 0
    WHERE a.id_licencia = p_id_licencia
      AND a.vigente = 'V'
      AND a.misma_forma = 'S'
      AND COALESCE(s.saldo, 0) > 0;

    GET DIAGNOSTICS v_count = v_count + ROW_COUNT;

    -- Calcular total de adeudo
    SELECT COALESCE(SUM(importe), 0.00)
    INTO v_total
    FROM public.tmp_adeudolic
    WHERE id_licencia = p_id_licencia;

    -- Retornar resultado
    RETURN QUERY
    SELECT
        v_count as registros_insertados,
        v_total as total_adeudo,
        CASE
            WHEN v_count = 0 THEN 'No hay adeudos para esta licencia'
            ELSE 'Adeudos calculados correctamente'
        END::VARCHAR(255) as mensaje;
END;
$$;

COMMENT ON FUNCTION comun.sp_imp_licencia_reglamentada_calcular_adeudo(INTEGER) IS
'Calcula adeudos de licencia y anuncios - Llena tmp_adeudolic con detalle de saldos';

-- ============================================
-- SP 4/4: sp_imp_licencia_reglamentada_detalle_saldo
-- Tipo: Query
-- Descripción: Obtiene el detalle de saldos de tmp_adeudolic
--              Retorna el desglose de adeudos calculados
-- --------------------------------------------

CREATE OR REPLACE FUNCTION comun.sp_imp_licencia_reglamentada_detalle_saldo(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    id_registro INTEGER,
    numero VARCHAR(50),
    texto VARCHAR(255),
    ctaapl VARCHAR(20),
    importe NUMERIC(12,2),
    tipo_adeudo VARCHAR(20),
    total_general NUMERIC(12,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(12,2) := 0.00;
BEGIN
    -- Validar parámetros
    IF p_id_licencia IS NULL THEN
        RAISE EXCEPTION 'ID de licencia es requerido';
    END IF;

    -- Calcular total general
    SELECT COALESCE(SUM(t.importe), 0.00)
    INTO v_total
    FROM public.tmp_adeudolic t
    WHERE t.id_licencia = p_id_licencia;

    -- Retornar detalle de adeudos
    RETURN QUERY
    SELECT
        t.id_registro,
        COALESCE(t.numero, '') as numero,
        COALESCE(t.texto, '') as texto,
        COALESCE(t.ctaapl, '') as ctaapl,
        COALESCE(t.importe, 0.00) as importe,
        CASE
            WHEN t.texto LIKE '%ANUNCIO%' THEN 'ANUNCIO'
            WHEN t.texto LIKE '%LICENCIA%' THEN 'LICENCIA'
            ELSE 'OTRO'
        END::VARCHAR(20) as tipo_adeudo,
        v_total as total_general
    FROM public.tmp_adeudolic t
    WHERE t.id_licencia = p_id_licencia
    ORDER BY t.id_registro;

    -- Si no hay resultados, retornar mensaje
    IF NOT FOUND THEN
        RAISE NOTICE 'No hay adeudos registrados para la licencia %. Ejecute sp_imp_licencia_reglamentada_calcular_adeudo primero.', p_id_licencia;
    END IF;
END;
$$;

COMMENT ON FUNCTION comun.sp_imp_licencia_reglamentada_detalle_saldo(INTEGER) IS
'Obtiene detalle de saldos de tmp_adeudolic - Debe ejecutarse después de calcular_adeudo';

-- ============================================
-- ALIAS Y COMPATIBILIDAD CON CÓDIGO LEGACY
-- ============================================

-- Alias para compatibilidad con código legacy
CREATE OR REPLACE FUNCTION public.calc_adeudolic(p_id_licencia INTEGER)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM comun.sp_imp_licencia_reglamentada_calcular_adeudo(p_id_licencia);
END;
$$;

COMMENT ON FUNCTION public.calc_adeudolic(INTEGER) IS
'LEGACY - Usar comun.sp_imp_licencia_reglamentada_calcular_adeudo';

-- Alias para obtener datos de licencia reglamentada
CREATE OR REPLACE FUNCTION public.get_licencia_reglamentada(p_numero_licencia VARCHAR)
RETURNS TABLE(
    id_licencia INTEGER,
    numero_licencia INTEGER,
    folio VARCHAR,
    recaud VARCHAR,
    propietario VARCHAR,
    razon_social VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    actividad VARCHAR,
    ubicacion TEXT,
    cvecalle INTEGER,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    numint_ubic INTEGER,
    letraint_ubic VARCHAR,
    colonia VARCHAR,
    codigo_postal VARCHAR,
    zona VARCHAR,
    subzona VARCHAR,
    sup_autorizada NUMERIC,
    num_cajones INTEGER,
    aforo INTEGER,
    id_giro INTEGER,
    giro_descripcion VARCHAR,
    giro_clasificacion VARCHAR,
    giro_reglamentada VARCHAR,
    ctaaplic VARCHAR,
    cvecatnva VARCHAR,
    subpredio VARCHAR,
    espubic TEXT,
    fecha_consejo DATE,
    asiento INTEGER,
    bloqueado INTEGER,
    vigente VARCHAR,
    fecha_expedicion DATE,
    fecha_vencimiento DATE,
    estado VARCHAR,
    url_pdf TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM comun.sp_imp_licencia_reglamentada_get(p_numero_licencia, NULL);
END;
$$;

COMMENT ON FUNCTION public.get_licencia_reglamentada(VARCHAR) IS
'LEGACY - Usar comun.sp_imp_licencia_reglamentada_get';

-- Alias para verificar bloqueo
CREATE OR REPLACE FUNCTION public.check_licencia_bloqueada(p_id_licencia INTEGER)
RETURNS TABLE(
    esta_bloqueada BOOLEAN,
    tipo_bloqueo INTEGER,
    descripcion_bloqueo VARCHAR,
    motivo_bloqueo TEXT,
    fecha_bloqueo DATE,
    usuario_bloqueo VARCHAR,
    permite_impresion BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM comun.sp_imp_licencia_reglamentada_check_bloqueada(p_id_licencia);
END;
$$;

COMMENT ON FUNCTION public.check_licencia_bloqueada(INTEGER) IS
'LEGACY - Usar comun.sp_imp_licencia_reglamentada_check_bloqueada';

-- Alias para detalle de saldo
CREATE OR REPLACE FUNCTION public.detsaldo_licencia(p_id_licencia INTEGER)
RETURNS TABLE(
    id_registro INTEGER,
    numero VARCHAR,
    texto VARCHAR,
    ctaapl VARCHAR,
    importe NUMERIC,
    tipo_adeudo VARCHAR,
    total_general NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM comun.sp_imp_licencia_reglamentada_detalle_saldo(p_id_licencia);
END;
$$;

COMMENT ON FUNCTION public.detsaldo_licencia(INTEGER) IS
'LEGACY - Usar comun.sp_imp_licencia_reglamentada_detalle_saldo';

-- ============================================
-- GRANTS DE PERMISOS
-- ============================================

-- Permisos para funciones principales
GRANT EXECUTE ON FUNCTION comun.sp_imp_licencia_reglamentada_get(VARCHAR, INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.sp_imp_licencia_reglamentada_check_bloqueada(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.sp_imp_licencia_reglamentada_calcular_adeudo(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION comun.sp_imp_licencia_reglamentada_detalle_saldo(INTEGER) TO PUBLIC;

-- Permisos para funciones legacy
GRANT EXECUTE ON FUNCTION public.calc_adeudolic(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_licencia_reglamentada(VARCHAR) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.check_licencia_bloqueada(INTEGER) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.detsaldo_licencia(INTEGER) TO PUBLIC;

-- Permisos para tabla temporal
GRANT ALL ON TABLE public.tmp_adeudolic TO PUBLIC;
GRANT USAGE, SELECT ON SEQUENCE public.tmp_adeudolic_id_registro_seq TO PUBLIC;

-- ============================================
-- EJEMPLOS DE USO
-- ============================================

/*
-- 1. Obtener datos completos de una licencia reglamentada
SELECT * FROM comun.sp_imp_licencia_reglamentada_get('12345', NULL);
SELECT * FROM comun.sp_imp_licencia_reglamentada_get(NULL, 100);

-- 2. Verificar si está bloqueada
SELECT * FROM comun.sp_imp_licencia_reglamentada_check_bloqueada(100);

-- 3. Calcular adeudos
SELECT * FROM comun.sp_imp_licencia_reglamentada_calcular_adeudo(100);

-- 4. Obtener detalle de saldos
SELECT * FROM comun.sp_imp_licencia_reglamentada_detalle_saldo(100);

-- 5. Proceso completo de impresión
DO $$
DECLARE
    v_id_licencia INTEGER := 100;
    v_bloqueada BOOLEAN;
    v_permite_impresion BOOLEAN;
BEGIN
    -- Verificar bloqueo
    SELECT esta_bloqueada, permite_impresion
    INTO v_bloqueada, v_permite_impresion
    FROM comun.sp_imp_licencia_reglamentada_check_bloqueada(v_id_licencia);

    IF v_permite_impresion THEN
        -- Calcular adeudos
        PERFORM comun.sp_imp_licencia_reglamentada_calcular_adeudo(v_id_licencia);

        -- Mostrar detalle
        RAISE NOTICE 'Licencia % lista para impresión', v_id_licencia;
    ELSE
        RAISE NOTICE 'Licencia % bloqueada - No se puede imprimir', v_id_licencia;
    END IF;
END;
$$;

-- 6. Usando funciones legacy (compatibilidad)
SELECT * FROM public.get_licencia_reglamentada('12345');
SELECT public.calc_adeudolic(100);
SELECT * FROM public.detsaldo_licencia(100);
*/

-- ============================================
-- NOTAS PARA LA IMPLEMENTACIÓN
-- ============================================

/*
ESTRUCTURA DE TABLAS REQUERIDAS:
--------------------------------

1. public.licencias (tabla principal)
   - id_licencia, numero_licencia, folio, recaud, propietario, razonsoc
   - rfc, curp, ubicacion, cvecalle, numext_ubic, letraext_ubic, etc.
   - id_giro, zona, subzona, sup_autorizada, num_cajones, aforo
   - bloqueado, vigente, fecalt, fecven

2. public.c_giros (catálogo de giros)
   - id_giro, descripcion, clasificacion, reglamentada, ctaaplic

3. public.bloqueo (bloqueos de licencias)
   - id_licencia, bloqueado, observa, capturista, fecha_mov, vigente

4. public.c_tipobloqueo (tipos de bloqueo)
   - id, descripcion

5. public.convcta (cuentas catastrales)
   - cvecuenta, cvecatnva, subpredio

6. public.anuncios (anuncios asociados)
   - id_anuncio, id_licencia, num_anuncio, id_giro, vigente, misma_forma

7. public.detsal_lic (detalle saldos licencias)
   - id_licencia, id_anuncio, cvepago, saldo

8. public.tmp_adeudolic (temporal para adeudos)
   - id_registro, id_licencia, numero, texto, ctaapl, importe

ENDPOINTS DEL CONTROLADOR LARAVEL:
----------------------------------

1. POST /api/execute (action: "getLicenciaReglamentada")
   params: {licencia: "12345"} o {id_licencia: 100}
   Llamar: sp_imp_licencia_reglamentada_get

2. POST /api/execute (action: "checkLicenciaBloqueada")
   params: {id_licencia: 100}
   Llamar: sp_imp_licencia_reglamentada_check_bloqueada

3. POST /api/execute (action: "calcAdeudoLicencia")
   params: {id_licencia: 100}
   Llamar: sp_imp_licencia_reglamentada_calcular_adeudo

4. POST /api/execute (action: "getTmpAdeudoLic")
   params: {id_licencia: 100}
   Llamar: sp_imp_licencia_reglamentada_detalle_saldo

VALIDACIONES IMPLEMENTADAS:
---------------------------

1. Licencia existe y está vigente
2. Clasificación del giro = 'D' (reglamentada)
3. Licencia no bloqueada (bloqueado = 0)
4. Cálculo de adeudos incluye licencia + anuncios
5. Solo anuncios con misma_forma = 'S'
6. Solo registros con saldo > 0

CARACTERÍSTICAS ESPECIALES:
--------------------------

1. Soporte para búsqueda por número o ID de licencia
2. Verificación múltiple de bloqueos (tipo, motivo, fecha)
3. Cálculo automático de adeudos de licencia + anuncios
4. Tabla temporal para detalle de impresión
5. URL dinámica para PDF
6. Compatibilidad con código legacy
7. Manejo robusto de NULL con COALESCE
8. Validaciones exhaustivas de datos
9. Mensajes de error descriptivos
10. Funciones transaccionales

FLUJO DE IMPRESIÓN:
------------------

1. Buscar licencia: sp_imp_licencia_reglamentada_get
2. Verificar bloqueo: sp_imp_licencia_reglamentada_check_bloqueada
3. Validar clasificación = 'D' y permite_impresion = TRUE
4. Calcular adeudos: sp_imp_licencia_reglamentada_calcular_adeudo
5. Obtener detalle: sp_imp_licencia_reglamentada_detalle_saldo
6. Generar PDF con datos + adeudos
7. Limpiar tmp_adeudolic (opcional)

MANTENIMIENTO:
-------------

1. Limpiar tmp_adeudolic periódicamente:
   DELETE FROM public.tmp_adeudolic
   WHERE fecha_calculo < CURRENT_DATE - INTERVAL '7 days';

2. Verificar índices:
   REINDEX TABLE public.tmp_adeudolic;

3. Analizar estadísticas:
   ANALYZE public.tmp_adeudolic;
*/

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'STORED PROCEDURES IMPLICENCIAREGLAMENTADAFRM';
    RAISE NOTICE '====================================================';
    RAISE NOTICE 'Total de SPs creados: 4';
    RAISE NOTICE '1. sp_imp_licencia_reglamentada_get';
    RAISE NOTICE '2. sp_imp_licencia_reglamentada_check_bloqueada';
    RAISE NOTICE '3. sp_imp_licencia_reglamentada_calcular_adeudo';
    RAISE NOTICE '4. sp_imp_licencia_reglamentada_detalle_saldo';
    RAISE NOTICE '';
    RAISE NOTICE 'Funciones legacy compatibles: 4';
    RAISE NOTICE '- calc_adeudolic';
    RAISE NOTICE '- get_licencia_reglamentada';
    RAISE NOTICE '- check_licencia_bloqueada';
    RAISE NOTICE '- detsaldo_licencia';
    RAISE NOTICE '';
    RAISE NOTICE 'Tabla temporal creada: tmp_adeudolic';
    RAISE NOTICE 'Esquema: comun';
    RAISE NOTICE 'Estado: LISTO PARA DEPLOY';
    RAISE NOTICE '====================================================';
END;
$$;
