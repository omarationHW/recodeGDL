-- ==============================================================================
-- COMPONENTE: dictamenfrm
-- MÓDULO: padron_licencias
-- SCHEMA: comun
-- DESCRIPCIÓN: Stored procedures para gestión de dictámenes de uso de suelo
-- FECHA: 2025-11-20
-- ==============================================================================
-- RESUMEN:
-- Este archivo contiene 4 stored procedures implementados con lógica real
-- basándose en el análisis del componente Vue dictamenfrm.vue
--
-- TABLA PRINCIPAL: comun.dictamenes
-- - Gestión de dictámenes de uso de suelo
-- - Estados: 0=NEGADO, 1=APROBADO, 2=EN PROCESO, 3=PENDIENTE
-- ==============================================================================

-- ==================== STORED PROCEDURE 1/4 ====================
-- sp_dictamenes_estadisticas
-- Descripción: Obtiene estadísticas agregadas de todos los dictámenes
-- Parámetros: Ninguno
-- Retorna: Contadores y promedios de dictámenes
-- Uso en Vue: Línea 832 - Carga inicial de estadísticas en cards
-- ==============================================================

DROP FUNCTION IF EXISTS comun.sp_dictamenes_estadisticas() CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_dictamenes_estadisticas()
RETURNS TABLE(
    total_dictamenes BIGINT,
    dictamenes_aprobados BIGINT,
    dictamenes_rechazados BIGINT,
    dictamenes_en_proceso BIGINT,
    dictamenes_pendientes BIGINT,
    promedio_superficie NUMERIC,
    promedio_area_util NUMERIC
) AS $$
BEGIN
    -- Retornar estadísticas agregadas de la tabla dictamenes
    -- Contadores por estado y promedios de superficies
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT as total_dictamenes,
        COUNT(*) FILTER (WHERE d.dictamen = '1')::BIGINT as dictamenes_aprobados,
        COUNT(*) FILTER (WHERE d.dictamen = '0')::BIGINT as dictamenes_rechazados,
        COUNT(*) FILTER (WHERE d.dictamen = '2')::BIGINT as dictamenes_en_proceso,
        COUNT(*) FILTER (WHERE d.dictamen = '3')::BIGINT as dictamenes_pendientes,
        COALESCE(AVG(d.supconst), 0)::NUMERIC(10,2) as promedio_superficie,
        COALESCE(AVG(d.area_util), 0)::NUMERIC(10,2) as promedio_area_util
    FROM comun.dictamenes d;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_dictamenes_estadisticas() IS
'Obtiene estadísticas agregadas de dictámenes: totales por estado y promedios de superficies';

-- ==================== STORED PROCEDURE 2/4 ====================
-- sp_dictamenes_list
-- Descripción: Lista dictámenes con paginación y filtros de búsqueda
-- Parámetros:
--   - p_page: Número de página (default 1)
--   - p_page_size: Tamaño de página (default 10)
--   - p_propietario: Filtro por nombre propietario (opcional)
--   - p_domicilio: Filtro por domicilio (opcional)
--   - p_actividad: Filtro por actividad (opcional)
-- Retorna: Lista paginada de dictámenes con total_count
-- Uso en Vue: Línea 876 - Búsqueda y listado de dictámenes
-- ==============================================================

DROP FUNCTION IF EXISTS comun.sp_dictamenes_list(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_dictamenes_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 10,
    p_propietario VARCHAR DEFAULT NULL,
    p_domicilio VARCHAR DEFAULT NULL,
    p_actividad VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    id_dictamen INTEGER,
    id_giro INTEGER,
    propietario VARCHAR,
    domicilio VARCHAR,
    actividad VARCHAR,
    no_exterior VARCHAR,
    no_interior VARCHAR,
    supconst DOUBLE PRECISION,
    area_util DOUBLE PRECISION,
    num_cajones INTEGER,
    uso_suelo VARCHAR,
    desc_uso VARCHAR,
    zona INTEGER,
    subzona INTEGER,
    dictamen VARCHAR,
    fecha DATE,
    capturista VARCHAR,
    total_count BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_page_size;

    -- Retornar registros paginados con filtros aplicados
    -- Los filtros buscan coincidencias parciales (LIKE) en mayúsculas
    RETURN QUERY
    SELECT
        d.id_dictamen,
        d.id_giro,
        d.propietario,
        d.domicilio,
        d.actividad,
        d.no_exterior,
        d.no_interior,
        d.supconst,
        d.area_util,
        d.num_cajones,
        d.uso_suelo,
        d.desc_uso,
        d.zona,
        d.subzona,
        d.dictamen,
        d.fecha,
        d.capturista,
        COUNT(*) OVER() as total_count  -- Total de registros que cumplen los filtros
    FROM comun.dictamenes d
    WHERE (p_propietario IS NULL OR UPPER(d.propietario) LIKE '%' || UPPER(p_propietario) || '%')
      AND (p_domicilio IS NULL OR UPPER(d.domicilio) LIKE '%' || UPPER(p_domicilio) || '%')
      AND (p_actividad IS NULL OR UPPER(d.actividad) LIKE '%' || UPPER(p_actividad) || '%')
    ORDER BY d.fecha DESC, d.id_dictamen DESC  -- Más recientes primero
    LIMIT p_page_size
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_dictamenes_list(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR) IS
'Lista dictámenes con paginación y filtros opcionales por propietario, domicilio y actividad';

-- ==================== STORED PROCEDURE 3/4 ====================
-- sp_dictamenes_create
-- Descripción: Crea un nuevo dictamen con validaciones
-- Parámetros:
--   - p_id_giro: ID del giro (requerido)
--   - p_propietario: Nombre del propietario (requerido)
--   - p_domicilio: Domicilio del inmueble (requerido)
--   - p_actividad: Descripción de la actividad (requerido)
--   - p_no_exterior: Número exterior (opcional)
--   - p_no_interior: Número interior (opcional)
--   - p_supconst: Superficie construida en m² (opcional)
--   - p_area_util: Área útil en m² (opcional)
--   - p_num_cajones: Número de cajones de estacionamiento (default 0)
--   - p_uso_suelo: Uso de suelo permitido (opcional)
--   - p_desc_uso: Descripción adicional de uso (opcional)
--   - p_zona: Zona de ubicación (opcional)
--   - p_subzona: Subzona de ubicación (opcional)
--   - p_dictamen: Estado del dictamen (default '3'=PENDIENTE)
-- Retorna: success, message, id_dictamen
-- Uso en Vue: Línea 1002 - Creación de nuevo dictamen
-- ==============================================================

DROP FUNCTION IF EXISTS comun.sp_dictamenes_create(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_dictamenes_create(
    p_id_giro INTEGER,
    p_propietario VARCHAR,
    p_domicilio VARCHAR,
    p_actividad VARCHAR,
    p_no_exterior VARCHAR DEFAULT NULL,
    p_no_interior VARCHAR DEFAULT NULL,
    p_supconst DOUBLE PRECISION DEFAULT NULL,
    p_area_util DOUBLE PRECISION DEFAULT NULL,
    p_num_cajones INTEGER DEFAULT 0,
    p_uso_suelo VARCHAR DEFAULT NULL,
    p_desc_uso VARCHAR DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_subzona INTEGER DEFAULT NULL,
    p_dictamen VARCHAR DEFAULT '3'
)
RETURNS TABLE(success BOOLEAN, message TEXT, id_dictamen INTEGER) AS $$
DECLARE
    v_id_dictamen INTEGER;
    v_propietario VARCHAR;
    v_domicilio VARCHAR;
    v_actividad VARCHAR;
BEGIN
    -- Normalizar y validar campos requeridos
    v_propietario := TRIM(p_propietario);
    v_domicilio := TRIM(p_domicilio);
    v_actividad := TRIM(p_actividad);

    -- Validación 1: Propietario es obligatorio
    IF v_propietario IS NULL OR v_propietario = '' THEN
        RETURN QUERY SELECT FALSE, 'El propietario es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validación 2: Domicilio es obligatorio
    IF v_domicilio IS NULL OR v_domicilio = '' THEN
        RETURN QUERY SELECT FALSE, 'El domicilio es requerido'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validación 3: Actividad es obligatoria
    IF v_actividad IS NULL OR v_actividad = '' THEN
        RETURN QUERY SELECT FALSE, 'La actividad es requerida'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Validación 4: Verificar que el dictamen sea un valor válido (0, 1, 2, 3)
    IF p_dictamen NOT IN ('0', '1', '2', '3') THEN
        RETURN QUERY SELECT FALSE, 'El estado del dictamen no es válido (0=NEGADO, 1=APROBADO, 2=EN PROCESO, 3=PENDIENTE)'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Insertar el nuevo dictamen
    -- Todos los campos de texto se guardan en MAYÚSCULAS
    INSERT INTO comun.dictamenes (
        id_giro,
        propietario,
        domicilio,
        actividad,
        no_exterior,
        no_interior,
        supconst,
        area_util,
        num_cajones,
        uso_suelo,
        desc_uso,
        zona,
        subzona,
        dictamen,
        fecha,
        capturista
    ) VALUES (
        p_id_giro,
        UPPER(v_propietario),
        UPPER(v_domicilio),
        UPPER(v_actividad),
        CASE WHEN TRIM(p_no_exterior) = '' THEN NULL ELSE UPPER(TRIM(p_no_exterior)) END,
        CASE WHEN TRIM(p_no_interior) = '' THEN NULL ELSE UPPER(TRIM(p_no_interior)) END,
        p_supconst,
        p_area_util,
        COALESCE(p_num_cajones, 0),
        CASE WHEN TRIM(p_uso_suelo) = '' THEN NULL ELSE UPPER(TRIM(p_uso_suelo)) END,
        CASE WHEN TRIM(p_desc_uso) = '' THEN NULL ELSE UPPER(TRIM(p_desc_uso)) END,
        p_zona,
        p_subzona,
        p_dictamen,
        CURRENT_DATE,
        'sistema'
    )
    RETURNING dictamenes.id_dictamen INTO v_id_dictamen;

    -- Retornar éxito con el ID generado
    RETURN QUERY SELECT TRUE, 'Dictamen creado exitosamente'::TEXT, v_id_dictamen;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_dictamenes_create(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER, VARCHAR) IS
'Crea un nuevo dictamen con validaciones de campos requeridos y retorna el ID generado';

-- ==================== STORED PROCEDURE 4/4 ====================
-- sp_dictamenes_update
-- Descripción: Actualiza un dictamen existente
-- Parámetros:
--   - p_id_dictamen: ID del dictamen a actualizar (requerido)
--   - p_id_giro: ID del giro (requerido)
--   - p_propietario: Nombre del propietario (requerido)
--   - p_domicilio: Domicilio del inmueble (requerido)
--   - p_actividad: Descripción de la actividad (requerido)
--   - p_no_exterior: Número exterior (opcional)
--   - p_no_interior: Número interior (opcional)
--   - p_supconst: Superficie construida en m² (opcional)
--   - p_area_util: Área útil en m² (opcional)
--   - p_num_cajones: Número de cajones de estacionamiento (default 0)
--   - p_uso_suelo: Uso de suelo permitido (opcional)
--   - p_desc_uso: Descripción adicional de uso (opcional)
--   - p_zona: Zona de ubicación (opcional)
--   - p_subzona: Subzona de ubicación (opcional)
--   - p_dictamen: Estado del dictamen (default '3'=PENDIENTE)
-- Retorna: success, message
-- Uso en Vue: Línea 1070 - Actualización de dictamen existente
-- ==============================================================

DROP FUNCTION IF EXISTS comun.sp_dictamenes_update(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, VARCHAR, VARCHAR, INTEGER, VARCHAR, VARCHAR) CASCADE;

CREATE OR REPLACE FUNCTION comun.sp_dictamenes_update(
    p_id_dictamen INTEGER,
    p_id_giro INTEGER,
    p_propietario VARCHAR,
    p_domicilio VARCHAR,
    p_actividad VARCHAR,
    p_no_exterior VARCHAR DEFAULT NULL,
    p_no_interior VARCHAR DEFAULT NULL,
    p_supconst DOUBLE PRECISION DEFAULT NULL,
    p_area_util DOUBLE PRECISION DEFAULT NULL,
    p_num_cajones INTEGER DEFAULT 0,
    p_uso_suelo VARCHAR DEFAULT NULL,
    p_desc_uso VARCHAR DEFAULT NULL,
    p_zona INTEGER DEFAULT NULL,
    p_subzona VARCHAR DEFAULT NULL,
    p_dictamen VARCHAR DEFAULT '3'
)
RETURNS TABLE(success BOOLEAN, message TEXT) AS $$
DECLARE
    v_propietario VARCHAR;
    v_domicilio VARCHAR;
    v_actividad VARCHAR;
    v_subzona_int INTEGER;
    v_updated_rows INTEGER;
BEGIN
    -- Normalizar campos requeridos
    v_propietario := TRIM(p_propietario);
    v_domicilio := TRIM(p_domicilio);
    v_actividad := TRIM(p_actividad);

    -- Validación 1: Propietario es obligatorio
    IF v_propietario IS NULL OR v_propietario = '' THEN
        RETURN QUERY SELECT FALSE, 'El propietario es requerido'::TEXT;
        RETURN;
    END IF;

    -- Validación 2: Domicilio es obligatorio
    IF v_domicilio IS NULL OR v_domicilio = '' THEN
        RETURN QUERY SELECT FALSE, 'El domicilio es requerido'::TEXT;
        RETURN;
    END IF;

    -- Validación 3: Actividad es obligatoria
    IF v_actividad IS NULL OR v_actividad = '' THEN
        RETURN QUERY SELECT FALSE, 'La actividad es requerida'::TEXT;
        RETURN;
    END IF;

    -- Validación 4: Verificar que el dictamen exista
    IF NOT EXISTS (SELECT 1 FROM comun.dictamenes WHERE id_dictamen = p_id_dictamen) THEN
        RETURN QUERY SELECT FALSE, 'Dictamen no encontrado'::TEXT;
        RETURN;
    END IF;

    -- Validación 5: Verificar que el dictamen sea un valor válido
    IF p_dictamen NOT IN ('0', '1', '2', '3') THEN
        RETURN QUERY SELECT FALSE, 'El estado del dictamen no es válido (0=NEGADO, 1=APROBADO, 2=EN PROCESO, 3=PENDIENTE)'::TEXT;
        RETURN;
    END IF;

    -- Convertir subzona de VARCHAR a INTEGER
    -- En el Vue se envía como VARCHAR pero la BD espera INTEGER
    BEGIN
        v_subzona_int := CAST(p_subzona AS INTEGER);
    EXCEPTION WHEN OTHERS THEN
        v_subzona_int := NULL;
    END;

    -- Actualizar el dictamen
    -- Todos los campos de texto se guardan en MAYÚSCULAS
    UPDATE comun.dictamenes
    SET
        id_giro = p_id_giro,
        propietario = UPPER(v_propietario),
        domicilio = UPPER(v_domicilio),
        actividad = UPPER(v_actividad),
        no_exterior = CASE WHEN TRIM(p_no_exterior) = '' THEN NULL ELSE UPPER(TRIM(p_no_exterior)) END,
        no_interior = CASE WHEN TRIM(p_no_interior) = '' THEN NULL ELSE UPPER(TRIM(p_no_interior)) END,
        supconst = p_supconst,
        area_util = p_area_util,
        num_cajones = COALESCE(p_num_cajones, 0),
        uso_suelo = CASE WHEN TRIM(p_uso_suelo) = '' THEN NULL ELSE UPPER(TRIM(p_uso_suelo)) END,
        desc_uso = CASE WHEN TRIM(p_desc_uso) = '' THEN NULL ELSE UPPER(TRIM(p_desc_uso)) END,
        zona = p_zona,
        subzona = v_subzona_int,
        dictamen = p_dictamen
    WHERE id_dictamen = p_id_dictamen;

    -- Verificar si se actualizó algún registro
    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows = 0 THEN
        RETURN QUERY SELECT FALSE, 'No se pudo actualizar el dictamen'::TEXT;
        RETURN;
    END IF;

    -- Retornar éxito
    RETURN QUERY SELECT TRUE, 'Dictamen actualizado exitosamente'::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_dictamenes_update(INTEGER, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, VARCHAR, VARCHAR, INTEGER, VARCHAR, VARCHAR) IS
'Actualiza un dictamen existente con validaciones de campos requeridos y existencia del registro';

-- ==============================================================================
-- SCRIPT DE VERIFICACIÓN
-- ==============================================================================
-- Verificar que los 4 stored procedures se crearon correctamente

DO $$
DECLARE
    v_count INTEGER;
    v_sp_name TEXT;
    v_status TEXT;
BEGIN
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'VERIFICACIÓN DE STORED PROCEDURES - COMPONENTE: dictamenfrm';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE '';

    -- Verificar cada stored procedure
    FOR v_sp_name IN
        SELECT unnest(ARRAY[
            'sp_dictamenes_estadisticas',
            'sp_dictamenes_list',
            'sp_dictamenes_create',
            'sp_dictamenes_update'
        ])
    LOOP
        SELECT COUNT(*) INTO v_count
        FROM pg_proc p
        INNER JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = v_sp_name;

        IF v_count > 0 THEN
            v_status := '✓ EXISTE';
        ELSE
            v_status := '✗ NO EXISTE';
        END IF;

        RAISE NOTICE '% comun.%()', v_status, v_sp_name;
    END LOOP;

    RAISE NOTICE '';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'RESUMEN DE IMPLEMENTACIÓN';
    RAISE NOTICE '=================================================================';
    RAISE NOTICE 'Componente Vue: dictamenfrm.vue';
    RAISE NOTICE 'Módulo: padron_licencias';
    RAISE NOTICE 'Schema: comun';
    RAISE NOTICE 'Total SPs: 4';
    RAISE NOTICE '';
    RAISE NOTICE 'FUNCIONALIDADES IMPLEMENTADAS:';
    RAISE NOTICE '1. sp_dictamenes_estadisticas - Estadísticas agregadas';
    RAISE NOTICE '2. sp_dictamenes_list - Listado paginado con filtros';
    RAISE NOTICE '3. sp_dictamenes_create - Creación con validaciones';
    RAISE NOTICE '4. sp_dictamenes_update - Actualización con validaciones';
    RAISE NOTICE '';
    RAISE NOTICE 'CARACTERÍSTICAS:';
    RAISE NOTICE '- Validación de campos requeridos';
    RAISE NOTICE '- Normalización de datos (UPPER, TRIM)';
    RAISE NOTICE '- Paginación con total_count';
    RAISE NOTICE '- Filtros de búsqueda con LIKE';
    RAISE NOTICE '- Manejo de estados: 0=NEGADO, 1=APROBADO, 2=EN PROCESO, 3=PENDIENTE';
    RAISE NOTICE '- Compatible con API genérica de Laravel';
    RAISE NOTICE '=================================================================';
END $$;

-- ==============================================================================
-- FIN DEL SCRIPT
-- ==============================================================================
