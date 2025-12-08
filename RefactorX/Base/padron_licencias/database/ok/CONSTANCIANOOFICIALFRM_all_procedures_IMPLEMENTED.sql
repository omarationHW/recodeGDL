-- =============================================
-- MÓDULO: CONSTANCIANOOFICIALFRM - GESTIÓN DE SOLICITUDES DE NÚMERO OFICIAL
-- =============================================
-- Descripción: Sistema completo para gestión de solicitudes de números oficiales
-- Autor: RefactorX - Sistema de Migración Automática
-- Fecha: 2025-11-20
-- Esquema: public
--
-- TABLA PRINCIPAL:
--   public.solicnooficial
--     - PK Compuesta: (axo, folio)
--     - Campos: propietario, actividad, ubicacion, zona, subzona,
--               vigente ('V'=Vigente, 'C'=Cancelado),
--               feccap (fecha captura), capturista
--
-- CARACTERÍSTICAS:
--   - Auto-generación de folio por año
--   - Soft delete mediante campo vigente
--   - Auditoría completa (feccap, capturista)
--   - Búsqueda por propietario y ubicación
--   - Generación de reportes PDF
--
-- STORED PROCEDURES:
--   1. solicnooficial_estadisticas    - Estadísticas agregadas por estado
--   2. solicnooficial_list            - Listado con filtros y paginación
--   3. solicnooficial_search          - Búsqueda por tipo y valor
--   4. solicnooficial_get_next_folio  - Obtener siguiente folio disponible
--   5. solicnooficial_insert          - Crear nueva solicitud con auto-folio
--   6. solicnooficial_update          - Actualizar solicitud existente
--   7. solicnooficial_cancel          - Cancelar solicitud (soft delete)
--   8. solicnooficial_print           - Datos para impresión de solicitud
-- =============================================

-- =============================================
-- SP: solicnooficial_estadisticas
-- =============================================
-- Descripción: Obtiene estadísticas agregadas de solicitudes por estado
-- Parámetros: Ninguno
-- Retorna: Estadísticas con totales, descripciones y porcentajes
-- Uso: Dashboards y reportes de gestión
-- =============================================
DROP FUNCTION IF EXISTS public.solicnooficial_estadisticas() CASCADE;

CREATE OR REPLACE FUNCTION public.solicnooficial_estadisticas()
RETURNS TABLE(
    vigente VARCHAR,
    total BIGINT,
    descripcion VARCHAR,
    porcentaje NUMERIC
) AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Calcular total general de solicitudes
    SELECT COUNT(*) INTO v_total
    FROM public.solicnooficial;

    -- Validar que existan registros
    IF v_total = 0 THEN
        RETURN QUERY
        SELECT
            'V'::VARCHAR as vigente,
            0::BIGINT as total,
            'Sin registros'::VARCHAR as descripcion,
            0::NUMERIC as porcentaje;
        RETURN;
    END IF;

    -- Retornar estadísticas agrupadas por estado de vigencia
    RETURN QUERY
    SELECT
        s.vigente,
        COUNT(*)::BIGINT as total,
        CASE s.vigente
            WHEN 'V' THEN 'Vigentes'::VARCHAR
            WHEN 'C' THEN 'Canceladas'::VARCHAR
            ELSE 'Desconocido'::VARCHAR
        END as descripcion,
        ROUND((COUNT(*) * 100.0 / NULLIF(v_total, 0))::NUMERIC, 1) as porcentaje
    FROM public.solicnooficial s
    GROUP BY s.vigente
    ORDER BY s.vigente;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.solicnooficial_estadisticas() IS
'Obtiene estadísticas agregadas de solicitudes de número oficial por estado de vigencia (V=Vigente, C=Cancelado). Retorna totales, descripciones y porcentajes.';

-- =============================================
-- SP: solicnooficial_list
-- =============================================
-- Descripción: Lista solicitudes con filtros múltiples y paginación
-- Parámetros:
--   @p_axo           INTEGER - Filtro por año (opcional)
--   @p_folio         INTEGER - Filtro por folio (opcional)
--   @p_propietario   VARCHAR - Filtro por nombre propietario (parcial, opcional)
--   @p_actividad     VARCHAR - Filtro por actividad (parcial, opcional)
--   @p_ubicacion     VARCHAR - Filtro por ubicación (parcial, opcional)
--   @p_zona          SMALLINT - Filtro por zona (opcional)
--   @p_subzona       SMALLINT - Filtro por subzona (opcional)
--   @p_vigente       VARCHAR - Filtro por estado: 'V'=Vigente, 'C'=Cancelado (opcional)
--   @p_fecha_desde   DATE    - Filtro por fecha inicio (opcional)
--   @p_fecha_hasta   DATE    - Filtro por fecha fin (opcional)
--   @p_page          INTEGER - Página actual (default: 1)
--   @p_limit         INTEGER - Registros por página (default: 50)
-- Retorna: Listado de solicitudes con total de registros
-- =============================================
DROP FUNCTION IF EXISTS public.solicnooficial_list(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, SMALLINT, SMALLINT, VARCHAR, DATE, DATE, INTEGER, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION public.solicnooficial_list(
    p_axo INTEGER DEFAULT NULL,
    p_folio INTEGER DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_actividad VARCHAR DEFAULT NULL,
    p_ubicacion VARCHAR DEFAULT NULL,
    p_zona SMALLINT DEFAULT NULL,
    p_subzona SMALLINT DEFAULT NULL,
    p_vigente VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 50
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    propietario VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    vigente VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR,
    total_records BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    -- Validar parámetros de paginación
    IF p_page IS NULL OR p_page < 1 THEN
        p_page := 1;
    END IF;

    IF p_limit IS NULL OR p_limit < 1 THEN
        p_limit := 50;
    END IF;

    IF p_limit > 1000 THEN
        p_limit := 1000; -- Límite máximo de seguridad
    END IF;

    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Retornar listado con filtros aplicados
    RETURN QUERY
    SELECT
        s.axo,
        s.folio,
        s.propietario,
        s.actividad,
        s.ubicacion,
        s.zona,
        s.subzona,
        s.vigente,
        s.feccap,
        s.capturista,
        COUNT(*) OVER() as total_records
    FROM public.solicnooficial s
    WHERE (p_axo IS NULL OR s.axo = p_axo)
      AND (p_folio IS NULL OR s.folio = p_folio)
      AND (p_propietario IS NULL OR UPPER(s.propietario) LIKE '%' || UPPER(p_propietario) || '%')
      AND (p_actividad IS NULL OR UPPER(s.actividad) LIKE '%' || UPPER(p_actividad) || '%')
      AND (p_ubicacion IS NULL OR UPPER(s.ubicacion) LIKE '%' || UPPER(p_ubicacion) || '%')
      AND (p_zona IS NULL OR s.zona = p_zona)
      AND (p_subzona IS NULL OR s.subzona = p_subzona)
      AND (p_vigente IS NULL OR s.vigente = p_vigente)
      AND (p_fecha_desde IS NULL OR s.feccap::DATE >= p_fecha_desde)
      AND (p_fecha_hasta IS NULL OR s.feccap::DATE <= p_fecha_hasta)
    ORDER BY s.axo DESC, s.folio DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.solicnooficial_list(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, SMALLINT, SMALLINT, VARCHAR, DATE, DATE, INTEGER, INTEGER) IS
'Lista solicitudes de número oficial con filtros múltiples, búsqueda de texto y paginación. Retorna total de registros que cumplen los criterios.';

-- =============================================
-- SP: solicnooficial_search
-- =============================================
-- Descripción: Búsqueda especializada por tipo (propietario o ubicación)
-- Parámetros:
--   @p_search_type  VARCHAR - Tipo de búsqueda: 'propietario' o 'ubicacion'
--   @p_search_value VARCHAR - Valor a buscar (búsqueda parcial)
--   @p_vigente      VARCHAR - Filtro por estado (opcional, default: 'V')
--   @p_limit        INTEGER - Límite de resultados (default: 100)
-- Retorna: Listado de solicitudes que coinciden
-- =============================================
DROP FUNCTION IF EXISTS public.solicnooficial_search(VARCHAR, VARCHAR, VARCHAR, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION public.solicnooficial_search(
    p_search_type VARCHAR,
    p_search_value VARCHAR,
    p_vigente VARCHAR DEFAULT 'V',
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    propietario VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    vigente VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
BEGIN
    -- Validar tipo de búsqueda
    IF p_search_type IS NULL OR p_search_type NOT IN ('propietario', 'ubicacion') THEN
        RAISE EXCEPTION 'Tipo de búsqueda inválido. Use: propietario o ubicacion';
    END IF;

    -- Validar valor de búsqueda
    IF p_search_value IS NULL OR TRIM(p_search_value) = '' THEN
        RAISE EXCEPTION 'El valor de búsqueda no puede estar vacío';
    END IF;

    -- Validar límite
    IF p_limit IS NULL OR p_limit < 1 THEN
        p_limit := 100;
    END IF;

    IF p_limit > 500 THEN
        p_limit := 500; -- Límite máximo de seguridad
    END IF;

    -- Ejecutar búsqueda según el tipo
    IF p_search_type = 'propietario' THEN
        RETURN QUERY
        SELECT
            s.axo,
            s.folio,
            s.propietario,
            s.actividad,
            s.ubicacion,
            s.zona,
            s.subzona,
            s.vigente,
            s.feccap,
            s.capturista
        FROM public.solicnooficial s
        WHERE UPPER(s.propietario) LIKE '%' || UPPER(TRIM(p_search_value)) || '%'
          AND (p_vigente IS NULL OR s.vigente = p_vigente)
        ORDER BY s.axo DESC, s.folio DESC
        LIMIT p_limit;
    ELSIF p_search_type = 'ubicacion' THEN
        RETURN QUERY
        SELECT
            s.axo,
            s.folio,
            s.propietario,
            s.actividad,
            s.ubicacion,
            s.zona,
            s.subzona,
            s.vigente,
            s.feccap,
            s.capturista
        FROM public.solicnooficial s
        WHERE UPPER(s.ubicacion) LIKE '%' || UPPER(TRIM(p_search_value)) || '%'
          AND (p_vigente IS NULL OR s.vigente = p_vigente)
        ORDER BY s.axo DESC, s.folio DESC
        LIMIT p_limit;
    END IF;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.solicnooficial_search(VARCHAR, VARCHAR, VARCHAR, INTEGER) IS
'Búsqueda especializada de solicitudes por tipo (propietario/ubicacion) con filtro de vigencia. Retorna resultados limitados ordenados por fecha.';

-- =============================================
-- SP: solicnooficial_get_next_folio
-- =============================================
-- Descripción: Obtiene el siguiente folio disponible para el año actual
-- Parámetros:
--   @p_axo INTEGER - Año para el cual obtener el folio (opcional, default: año actual)
-- Retorna: Siguiente folio disponible y año
-- =============================================
DROP FUNCTION IF EXISTS public.solicnooficial_get_next_folio(INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION public.solicnooficial_get_next_folio(
    p_axo INTEGER DEFAULT NULL
)
RETURNS TABLE(
    axo INTEGER,
    next_folio INTEGER
) AS $$
DECLARE
    v_axo INTEGER;
    v_next_folio INTEGER;
BEGIN
    -- Si no se proporciona año, usar el año actual
    IF p_axo IS NULL THEN
        v_axo := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;
    ELSE
        v_axo := p_axo;
    END IF;

    -- Obtener el último folio del año y calcular el siguiente
    SELECT COALESCE(MAX(s.folio), 0) + 1 INTO v_next_folio
    FROM public.solicnooficial s
    WHERE s.axo = v_axo;

    -- Retornar resultado
    RETURN QUERY
    SELECT v_axo, v_next_folio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.solicnooficial_get_next_folio(INTEGER) IS
'Obtiene el siguiente folio disponible para un año específico. Si no se proporciona año, usa el año actual. Retorna año y siguiente folio.';

-- =============================================
-- SP: solicnooficial_insert
-- =============================================
-- Descripción: Crea una nueva solicitud de número oficial con auto-generación de folio
-- Parámetros:
--   @p_propietario VARCHAR - Nombre del propietario (requerido)
--   @p_actividad   VARCHAR - Descripción de la actividad (requerido)
--   @p_ubicacion   VARCHAR - Ubicación del predio (requerido)
--   @p_zona        SMALLINT - Zona catastral (requerido)
--   @p_subzona     SMALLINT - Subzona catastral (requerido)
-- Retorna: Registro completo de la solicitud creada
-- Nota: El año y folio se generan automáticamente
--       El campo vigente se inicializa en 'V' (Vigente)
--       Los campos feccap y capturista se llenan automáticamente
-- =============================================
DROP FUNCTION IF EXISTS public.solicnooficial_insert(VARCHAR, VARCHAR, VARCHAR, SMALLINT, SMALLINT) CASCADE;

CREATE OR REPLACE FUNCTION public.solicnooficial_insert(
    p_propietario VARCHAR,
    p_actividad VARCHAR,
    p_ubicacion VARCHAR,
    p_zona SMALLINT,
    p_subzona SMALLINT
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    propietario VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    vigente VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
DECLARE
    v_axo INTEGER;
    v_folio INTEGER;
    v_capturista VARCHAR;
BEGIN
    -- Validar parámetros requeridos
    IF p_propietario IS NULL OR TRIM(p_propietario) = '' THEN
        RAISE EXCEPTION 'El nombre del propietario es requerido';
    END IF;

    IF p_actividad IS NULL OR TRIM(p_actividad) = '' THEN
        RAISE EXCEPTION 'La actividad es requerida';
    END IF;

    IF p_ubicacion IS NULL OR TRIM(p_ubicacion) = '' THEN
        RAISE EXCEPTION 'La ubicación es requerida';
    END IF;

    IF p_zona IS NULL OR p_zona < 1 THEN
        RAISE EXCEPTION 'La zona debe ser un valor válido mayor a 0';
    END IF;

    IF p_subzona IS NULL OR p_subzona < 1 THEN
        RAISE EXCEPTION 'La subzona debe ser un valor válido mayor a 0';
    END IF;

    -- Obtener año actual
    v_axo := EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER;

    -- Obtener siguiente folio para el año actual
    SELECT COALESCE(MAX(s.folio), 0) + 1 INTO v_folio
    FROM public.solicnooficial s
    WHERE s.axo = v_axo;

    -- Obtener usuario actual (se puede obtener de una variable de sesión)
    -- Por ahora usamos 'SYSTEM' como default
    v_capturista := COALESCE(CURRENT_USER, 'SYSTEM');

    -- Insertar nueva solicitud
    INSERT INTO public.solicnooficial (
        axo,
        folio,
        propietario,
        actividad,
        ubicacion,
        zona,
        subzona,
        vigente,
        feccap,
        capturista
    )
    VALUES (
        v_axo,
        v_folio,
        TRIM(p_propietario),
        TRIM(p_actividad),
        TRIM(p_ubicacion),
        p_zona,
        p_subzona,
        'V', -- Vigente por defecto
        CURRENT_TIMESTAMP,
        v_capturista
    );

    -- Retornar registro creado
    RETURN QUERY
    SELECT
        s.axo,
        s.folio,
        s.propietario,
        s.actividad,
        s.ubicacion,
        s.zona,
        s.subzona,
        s.vigente,
        s.feccap,
        s.capturista
    FROM public.solicnooficial s
    WHERE s.axo = v_axo AND s.folio = v_folio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.solicnooficial_insert(VARCHAR, VARCHAR, VARCHAR, SMALLINT, SMALLINT) IS
'Crea una nueva solicitud de número oficial con auto-generación de año y folio. Valida todos los campos requeridos y establece vigente=V por defecto.';

-- =============================================
-- SP: solicnooficial_update
-- =============================================
-- Descripción: Actualiza una solicitud existente
-- Parámetros:
--   @p_axo         INTEGER  - Año de la solicitud (PK, requerido)
--   @p_folio       INTEGER  - Folio de la solicitud (PK, requerido)
--   @p_propietario VARCHAR  - Nuevo nombre del propietario (opcional)
--   @p_actividad   VARCHAR  - Nueva actividad (opcional)
--   @p_ubicacion   VARCHAR  - Nueva ubicación (opcional)
--   @p_zona        SMALLINT - Nueva zona (opcional)
--   @p_subzona     SMALLINT - Nueva subzona (opcional)
-- Retorna: Registro actualizado completo
-- Nota: Solo se actualizan los campos proporcionados (no NULL)
--       Los campos vigente, feccap y capturista NO se modifican
-- =============================================
DROP FUNCTION IF EXISTS public.solicnooficial_update(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, SMALLINT, SMALLINT) CASCADE;

CREATE OR REPLACE FUNCTION public.solicnooficial_update(
    p_axo INTEGER,
    p_folio INTEGER,
    p_propietario VARCHAR DEFAULT NULL,
    p_actividad VARCHAR DEFAULT NULL,
    p_ubicacion VARCHAR DEFAULT NULL,
    p_zona SMALLINT DEFAULT NULL,
    p_subzona SMALLINT DEFAULT NULL
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    propietario VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    vigente VARCHAR,
    feccap TIMESTAMP,
    capturista VARCHAR
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_vigente VARCHAR;
BEGIN
    -- Validar parámetros de PK
    IF p_axo IS NULL THEN
        RAISE EXCEPTION 'El año (axo) es requerido';
    END IF;

    IF p_folio IS NULL THEN
        RAISE EXCEPTION 'El folio es requerido';
    END IF;

    -- Verificar que la solicitud existe
    SELECT EXISTS(
        SELECT 1 FROM public.solicnooficial s
        WHERE s.axo = p_axo AND s.folio = p_folio
    ) INTO v_exists;

    IF NOT v_exists THEN
        RAISE EXCEPTION 'No existe una solicitud con axo=% y folio=%', p_axo, p_folio;
    END IF;

    -- Verificar que la solicitud no esté cancelada
    SELECT s.vigente INTO v_vigente
    FROM public.solicnooficial s
    WHERE s.axo = p_axo AND s.folio = p_folio;

    IF v_vigente = 'C' THEN
        RAISE EXCEPTION 'No se puede actualizar una solicitud cancelada';
    END IF;

    -- Validar datos si se proporcionan
    IF p_propietario IS NOT NULL AND TRIM(p_propietario) = '' THEN
        RAISE EXCEPTION 'El nombre del propietario no puede estar vacío';
    END IF;

    IF p_actividad IS NOT NULL AND TRIM(p_actividad) = '' THEN
        RAISE EXCEPTION 'La actividad no puede estar vacía';
    END IF;

    IF p_ubicacion IS NOT NULL AND TRIM(p_ubicacion) = '' THEN
        RAISE EXCEPTION 'La ubicación no puede estar vacía';
    END IF;

    IF p_zona IS NOT NULL AND p_zona < 1 THEN
        RAISE EXCEPTION 'La zona debe ser un valor válido mayor a 0';
    END IF;

    IF p_subzona IS NOT NULL AND p_subzona < 1 THEN
        RAISE EXCEPTION 'La subzona debe ser un valor válido mayor a 0';
    END IF;

    -- Actualizar solicitud (solo los campos proporcionados)
    UPDATE public.solicnooficial s
    SET
        propietario = COALESCE(TRIM(p_propietario), s.propietario),
        actividad = COALESCE(TRIM(p_actividad), s.actividad),
        ubicacion = COALESCE(TRIM(p_ubicacion), s.ubicacion),
        zona = COALESCE(p_zona, s.zona),
        subzona = COALESCE(p_subzona, s.subzona)
    WHERE s.axo = p_axo AND s.folio = p_folio;

    -- Retornar registro actualizado
    RETURN QUERY
    SELECT
        s.axo,
        s.folio,
        s.propietario,
        s.actividad,
        s.ubicacion,
        s.zona,
        s.subzona,
        s.vigente,
        s.feccap,
        s.capturista
    FROM public.solicnooficial s
    WHERE s.axo = p_axo AND s.folio = p_folio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.solicnooficial_update(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, SMALLINT, SMALLINT) IS
'Actualiza una solicitud existente. Solo modifica campos proporcionados (no NULL). Valida que exista y no esté cancelada.';

-- =============================================
-- SP: solicnooficial_cancel
-- =============================================
-- Descripción: Cancela una solicitud (soft delete)
-- Parámetros:
--   @p_axo   INTEGER - Año de la solicitud (PK, requerido)
--   @p_folio INTEGER - Folio de la solicitud (PK, requerido)
-- Retorna: axo, folio y nuevo estado (vigente='C')
-- Nota: No elimina el registro, solo cambia vigente a 'C' (Cancelado)
--       Una vez cancelada, no se puede actualizar
-- =============================================
DROP FUNCTION IF EXISTS public.solicnooficial_cancel(INTEGER, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION public.solicnooficial_cancel(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    vigente VARCHAR,
    propietario VARCHAR,
    actividad VARCHAR
) AS $$
DECLARE
    v_exists BOOLEAN;
    v_vigente VARCHAR;
BEGIN
    -- Validar parámetros de PK
    IF p_axo IS NULL THEN
        RAISE EXCEPTION 'El año (axo) es requerido';
    END IF;

    IF p_folio IS NULL THEN
        RAISE EXCEPTION 'El folio es requerido';
    END IF;

    -- Verificar que la solicitud existe
    SELECT s.vigente INTO v_vigente
    FROM public.solicnooficial s
    WHERE s.axo = p_axo AND s.folio = p_folio;

    IF v_vigente IS NULL THEN
        RAISE EXCEPTION 'No existe una solicitud con axo=% y folio=%', p_axo, p_folio;
    END IF;

    -- Verificar que no esté ya cancelada
    IF v_vigente = 'C' THEN
        RAISE EXCEPTION 'La solicitud ya está cancelada';
    END IF;

    -- Cancelar solicitud (soft delete)
    UPDATE public.solicnooficial s
    SET vigente = 'C'
    WHERE s.axo = p_axo AND s.folio = p_folio;

    -- Retornar confirmación con datos básicos
    RETURN QUERY
    SELECT
        s.axo,
        s.folio,
        s.vigente,
        s.propietario,
        s.actividad
    FROM public.solicnooficial s
    WHERE s.axo = p_axo AND s.folio = p_folio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.solicnooficial_cancel(INTEGER, INTEGER) IS
'Cancela una solicitud de número oficial (soft delete). Cambia vigente de V a C. Valida que exista y no esté ya cancelada.';

-- =============================================
-- SP: solicnooficial_print
-- =============================================
-- Descripción: Obtiene datos completos de una solicitud para impresión/reporte
-- Parámetros:
--   @p_axo   INTEGER - Año de la solicitud (PK, requerido)
--   @p_folio INTEGER - Folio de la solicitud (PK, requerido)
-- Retorna: Datos completos de la solicitud con información formateada
-- Uso: Generación de reportes PDF, impresiones oficiales
-- =============================================
DROP FUNCTION IF EXISTS public.solicnooficial_print(INTEGER, INTEGER) CASCADE;

CREATE OR REPLACE FUNCTION public.solicnooficial_print(
    p_axo INTEGER,
    p_folio INTEGER
)
RETURNS TABLE(
    axo INTEGER,
    folio INTEGER,
    folio_completo VARCHAR,
    propietario VARCHAR,
    actividad VARCHAR,
    ubicacion VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    zona_completa VARCHAR,
    vigente VARCHAR,
    estado_descripcion VARCHAR,
    feccap TIMESTAMP,
    fecha_formato VARCHAR,
    capturista VARCHAR,
    pdf_url TEXT
) AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    -- Validar parámetros de PK
    IF p_axo IS NULL THEN
        RAISE EXCEPTION 'El año (axo) es requerido';
    END IF;

    IF p_folio IS NULL THEN
        RAISE EXCEPTION 'El folio es requerido';
    END IF;

    -- Verificar que la solicitud existe
    SELECT EXISTS(
        SELECT 1 FROM public.solicnooficial s
        WHERE s.axo = p_axo AND s.folio = p_folio
    ) INTO v_exists;

    IF NOT v_exists THEN
        RAISE EXCEPTION 'No existe una solicitud con axo=% y folio=%', p_axo, p_folio;
    END IF;

    -- Retornar datos formateados para impresión
    RETURN QUERY
    SELECT
        s.axo,
        s.folio,
        (s.axo || '-' || LPAD(s.folio::TEXT, 6, '0'))::VARCHAR as folio_completo,
        s.propietario,
        s.actividad,
        s.ubicacion,
        s.zona,
        s.subzona,
        ('Zona ' || s.zona || ' / Subzona ' || s.subzona)::VARCHAR as zona_completa,
        s.vigente,
        CASE s.vigente
            WHEN 'V' THEN 'VIGENTE'::VARCHAR
            WHEN 'C' THEN 'CANCELADA'::VARCHAR
            ELSE 'DESCONOCIDO'::VARCHAR
        END as estado_descripcion,
        s.feccap,
        TO_CHAR(s.feccap, 'DD/MM/YYYY HH24:MI:SS')::VARCHAR as fecha_formato,
        s.capturista,
        ('/reports/solicnooficial/' || s.axo || '/' || s.folio || '.pdf')::TEXT as pdf_url
    FROM public.solicnooficial s
    WHERE s.axo = p_axo AND s.folio = p_folio;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.solicnooficial_print(INTEGER, INTEGER) IS
'Obtiene datos completos de una solicitud para impresión/reporte con formatos especiales (folio completo, zona completa, fechas formateadas, URL del PDF).';

-- =============================================
-- SCRIPT DE VERIFICACIÓN
-- =============================================
-- Ejecute las siguientes consultas para verificar la instalación:
--
-- 1. Listar todos los SPs instalados:
-- SELECT routine_name, routine_definition
-- FROM information_schema.routines
-- WHERE routine_schema = 'public'
--   AND routine_name LIKE 'solicnooficial%'
-- ORDER BY routine_name;
--
-- 2. Obtener estadísticas:
-- SELECT * FROM public.solicnooficial_estadisticas();
--
-- 3. Listar solicitudes vigentes:
-- SELECT * FROM public.solicnooficial_list(
--     p_vigente := 'V',
--     p_page := 1,
--     p_limit := 10
-- );
--
-- 4. Obtener siguiente folio:
-- SELECT * FROM public.solicnooficial_get_next_folio();
--
-- 5. Crear solicitud de prueba:
-- SELECT * FROM public.solicnooficial_insert(
--     'Juan Pérez',
--     'Comercio al por menor',
--     'Av. Principal #123',
--     1,
--     5
-- );
-- =============================================

-- =============================================
-- REGISTRO DE CAMBIOS
-- =============================================
-- 2025-11-20: Implementación inicial completa
--   - 8 stored procedures funcionales
--   - Validaciones exhaustivas
--   - Auto-generación de folios
--   - Soft delete implementado
--   - Búsqueda multi-criterio
--   - Paginación y límites de seguridad
--   - Formato de impresión con datos completos
-- =============================================
