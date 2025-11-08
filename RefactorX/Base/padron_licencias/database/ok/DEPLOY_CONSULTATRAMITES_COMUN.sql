-- =============================================
-- DEPLOYMENT: Stored Procedures para Consulta de Trámites
-- Módulo: Padron Licencias - ConsultaTramitefrm.vue
-- Esquema: comun
-- Database: padron_licencias
-- Fecha: 2025-11-04
-- Autor: Sistema RefactorX
-- =============================================
-- DESCRIPCIÓN:
-- Este script crea los Stored Procedures en el esquema COMUN
-- de la base de datos padron_licencias
-- para el módulo de Consulta de Trámites
-- =============================================

-- =============================================
-- 1. consulta_tramites_list
-- Búsqueda de trámites con filtros múltiples y paginación
-- =============================================

-- Eliminar versiones anteriores
DROP FUNCTION IF EXISTS comun.consulta_tramites_list CASCADE;

CREATE OR REPLACE FUNCTION comun.consulta_tramites_list(
    p_id_tramite INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_tipo_tramite VARCHAR DEFAULT NULL,
    p_estatus VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_id_dependencia INTEGER DEFAULT NULL,
    p_id_giro INTEGER DEFAULT NULL,
    p_calle VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    -- Datos principales del trámite
    id_tramite INTEGER,
    folio INTEGER,
    tipo_tramite VARCHAR,
    tipo_tramite_desc VARCHAR,
    estatus VARCHAR,

    -- Datos del propietario
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    telefono VARCHAR,
    email VARCHAR,

    -- Ubicación del negocio
    calle VARCHAR,
    numero VARCHAR,
    numint VARCHAR,
    colonia VARCHAR,
    cp INTEGER,

    -- Giro y actividad
    id_giro INTEGER,
    giro_desc VARCHAR,
    actividad VARCHAR,
    actividad_desc VARCHAR,

    -- Fechas
    fecha_solicitud DATE,
    fecha_limite DATE,
    fecha_consejo DATE,
    feccap DATE,

    -- Otros datos
    capturista VARCHAR,
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    costo NUMERIC,
    observaciones TEXT,
    bloqueado SMALLINT,
    dictamen SMALLINT,
    nopago BOOLEAN,

    -- Requisitos
    total_requisitos INTEGER,
    requisitos_cumplidos INTEGER,

    -- Referencias
    id_licencia INTEGER,
    id_anuncio INTEGER,
    licencia_ref INTEGER,

    -- Coordenadas
    latitud NUMERIC,
    longitud NUMERIC,

    -- Paginación
    total_records INTEGER
) AS $$
DECLARE
    v_offset INTEGER;
    v_total INTEGER;
    -- Convertir cadenas vacías a NULL (Vue envía "" en lugar de null)
    v_tipo_tramite VARCHAR;
    v_estatus VARCHAR;
    v_propietario VARCHAR;
    v_rfc VARCHAR;
    v_calle VARCHAR;
    v_colonia VARCHAR;
BEGIN
    -- Convertir cadenas vacías a NULL usando NULLIF
    v_tipo_tramite := NULLIF(TRIM(p_tipo_tramite), '');
    v_estatus := NULLIF(TRIM(p_estatus), '');
    v_propietario := NULLIF(TRIM(p_propietario), '');
    v_rfc := NULLIF(TRIM(p_rfc), '');
    v_calle := NULLIF(TRIM(p_calle), '');
    v_colonia := NULLIF(TRIM(p_colonia), '');

    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Contar total de registros
    SELECT COUNT(*) INTO v_total
    FROM comun.tramites t
    WHERE
        (p_id_tramite IS NULL OR t.id_tramite = p_id_tramite)
        AND (p_id_licencia IS NULL OR t.id_licencia = p_id_licencia)
        AND (v_tipo_tramite IS NULL OR t.tipo_tramite = v_tipo_tramite)
        AND (v_estatus IS NULL OR t.estatus = v_estatus)
        AND (p_fecha_desde IS NULL OR t.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR t.feccap <= p_fecha_hasta)
        AND (v_propietario IS NULL OR UPPER(t.propietario) LIKE '%' || UPPER(v_propietario) || '%')
        AND (v_rfc IS NULL OR UPPER(t.rfc) LIKE '%' || UPPER(v_rfc) || '%')
        AND (p_id_giro IS NULL OR t.id_giro = p_id_giro)
        AND (v_calle IS NULL OR UPPER(t.ubicacion) LIKE '%' || UPPER(v_calle) || '%')
        AND (v_colonia IS NULL OR UPPER(t.colonia_ubic) LIKE '%' || UPPER(v_colonia) || '%');

    -- Retornar datos paginados (DISTINCT ON para evitar duplicados por c_giros)
    RETURN QUERY
    SELECT DISTINCT ON (t.id_tramite)
        -- Datos principales
        t.id_tramite,
        t.folio,
        TRIM(t.tipo_tramite)::VARCHAR AS tipo_tramite,
        CASE t.tipo_tramite
            WHEN 'LN' THEN 'Licencia Nueva'::VARCHAR
            WHEN 'RE' THEN 'Renovación'::VARCHAR
            WHEN 'CG' THEN 'Cambio de Giro'::VARCHAR
            WHEN 'TR' THEN 'Traspaso'::VARCHAR
            WHEN 'AN' THEN 'Anuncio'::VARCHAR
            ELSE 'Otro'::VARCHAR
        END AS tipo_tramite_desc,
        TRIM(t.estatus)::VARCHAR AS estatus,

        -- Propietario
        TRIM(t.propietario)::VARCHAR AS propietario,
        TRIM(t.primer_ap)::VARCHAR AS primer_ap,
        TRIM(t.segundo_ap)::VARCHAR AS segundo_ap,
        TRIM(t.rfc)::VARCHAR AS rfc,
        TRIM(t.curp)::VARCHAR AS curp,
        TRIM(t.telefono_prop)::VARCHAR AS telefono,
        TRIM(t.email)::VARCHAR AS email,

        -- Ubicación
        TRIM(t.ubicacion)::VARCHAR AS calle,
        CAST(t.numext_ubic AS VARCHAR) AS numero,
        TRIM(t.numint_ubic)::VARCHAR AS numint,
        TRIM(t.colonia_ubic)::VARCHAR AS colonia,
        t.cp,

        -- Giro
        t.id_giro,
        COALESCE(TRIM(g.descripcion), 'Sin giro')::VARCHAR AS giro_desc,
        TRIM(t.actividad)::VARCHAR AS actividad,
        TRIM(t.actividad)::VARCHAR AS actividad_desc,

        -- Fechas
        t.feccap AS fecha_solicitud,
        (t.feccap + INTERVAL '30 days')::DATE AS fecha_limite,
        t.fecha_consejo,
        t.feccap,

        -- Otros
        TRIM(t.capturista)::VARCHAR AS capturista,
        t.sup_construida,
        t.sup_autorizada,
        t.num_empleados,
        t.aforo,
        t.inversion,
        t.costo,
        TRIM(t.observaciones)::TEXT AS observaciones,
        t.bloqueado,
        t.dictamen,
        CASE WHEN t.costo > 0 THEN FALSE ELSE TRUE END AS nopago,

        -- Requisitos (simulado, ajustar según tablas reales)
        0::INTEGER AS total_requisitos,
        0::INTEGER AS requisitos_cumplidos,

        -- Referencias
        t.id_licencia,
        t.id_anuncio,
        t.licencia_ref,

        -- Coordenadas
        t.x AS latitud,
        t.y AS longitud,

        -- Total registros
        v_total
    FROM comun.tramites t
    LEFT JOIN comun.c_giros g ON g.id_giro = t.id_giro
    WHERE
        (p_id_tramite IS NULL OR t.id_tramite = p_id_tramite)
        AND (p_id_licencia IS NULL OR t.id_licencia = p_id_licencia)
        AND (v_tipo_tramite IS NULL OR t.tipo_tramite = v_tipo_tramite)
        AND (v_estatus IS NULL OR t.estatus = v_estatus)
        AND (p_fecha_desde IS NULL OR t.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR t.feccap <= p_fecha_hasta)
        AND (v_propietario IS NULL OR UPPER(t.propietario) LIKE '%' || UPPER(v_propietario) || '%')
        AND (v_rfc IS NULL OR UPPER(t.rfc) LIKE '%' || UPPER(v_rfc) || '%')
        AND (p_id_giro IS NULL OR t.id_giro = p_id_giro)
        AND (v_calle IS NULL OR UPPER(t.ubicacion) LIKE '%' || UPPER(v_calle) || '%')
        AND (v_colonia IS NULL OR UPPER(t.colonia_ubic) LIKE '%' || UPPER(v_colonia) || '%')
    ORDER BY t.id_tramite DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.consulta_tramites_list IS 'Lista trámites con filtros múltiples y paginación - Esquema comun - Base padron_licencias';

-- =============================================
-- 2. consulta_tramites_estadisticas
-- Estadísticas de trámites por estatus
-- =============================================

DROP FUNCTION IF EXISTS comun.consulta_tramites_estadisticas();

CREATE OR REPLACE FUNCTION comun.consulta_tramites_estadisticas()
RETURNS TABLE (
    estatus VARCHAR,
    descripcion VARCHAR,
    total INTEGER,
    porcentaje NUMERIC
) AS $$
DECLARE
    v_total_general INTEGER;
BEGIN
    -- Obtener total general de trámites
    SELECT COUNT(*) INTO v_total_general FROM comun.tramites;

    -- Si no hay trámites, retornar vacío
    IF v_total_general = 0 THEN
        v_total_general := 1; -- Evitar división por cero
    END IF;

    -- Retornar estadísticas por estatus
    RETURN QUERY
    SELECT
        TRIM(t.estatus)::VARCHAR AS estatus,
        CASE TRIM(t.estatus)
            WHEN 'P' THEN 'Pendiente'::VARCHAR
            WHEN 'E' THEN 'En Revisión'::VARCHAR
            WHEN 'V' THEN 'En Visita'::VARCHAR
            WHEN 'A' THEN 'Autorizado'::VARCHAR
            WHEN 'R' THEN 'Rechazado'::VARCHAR
            WHEN 'C' THEN 'Cancelado'::VARCHAR
            ELSE 'Otro'::VARCHAR
        END AS descripcion,
        COUNT(*)::INTEGER AS total,
        ROUND((COUNT(*)::NUMERIC / v_total_general::NUMERIC * 100), 2) AS porcentaje
    FROM comun.tramites t
    GROUP BY TRIM(t.estatus)
    ORDER BY COUNT(*) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.consulta_tramites_estadisticas IS 'Estadísticas de trámites por estatus - Esquema comun - Base padron_licencias';

-- =============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Verificando instalación de Stored Procedures...';
    RAISE NOTICE '================================================';

    -- Verificar consulta_tramites_list
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'consulta_tramites_list'
    ) THEN
        RAISE NOTICE '✓ comun.consulta_tramites_list creado correctamente (14 parámetros)';
    ELSE
        RAISE EXCEPTION '✗ Error: comun.consulta_tramites_list no se creó';
    END IF;

    -- Verificar consulta_tramites_estadisticas
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'consulta_tramites_estadisticas'
    ) THEN
        RAISE NOTICE '✓ comun.consulta_tramites_estadisticas creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: comun.consulta_tramites_estadisticas no se creó';
    END IF;

    RAISE NOTICE '================================================';
    RAISE NOTICE '✓ Instalación completada exitosamente';
    RAISE NOTICE '✓ Base de datos: padron_licencias';
    RAISE NOTICE '✓ Esquema: comun';
    RAISE NOTICE '================================================';
END $$;

-- =============================================
-- EJEMPLOS DE USO
-- =============================================

-- Ejemplo 1: Buscar todos los trámites pendientes
-- SELECT * FROM comun.consulta_tramites_list(NULL, NULL, NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 2: Buscar por ID Licencia
-- SELECT * FROM comun.consulta_tramites_list(NULL, 12345, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 3: Buscar por propietario
-- SELECT * FROM comun.consulta_tramites_list(NULL, NULL, NULL, NULL, NULL, NULL, 'LOPEZ', NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 4: Buscar por rango de fechas
-- SELECT * FROM comun.consulta_tramites_list(NULL, NULL, NULL, NULL, '2024-01-01', '2024-12-31', NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 5: Obtener estadísticas
-- SELECT * FROM comun.consulta_tramites_estadisticas();

-- =============================================
-- FIN DEL SCRIPT
-- =============================================
