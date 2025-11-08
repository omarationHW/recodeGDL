-- =============================================
-- DEPLOYMENT CORREGIDO: Stored Procedures para Consulta de Trámites
-- Módulo: Padron Licencias - ConsultaTramitefrm.vue
-- Esquema: comun
-- Fecha: 2025-11-04
-- Autor: Sistema RefactorX
-- =============================================
-- DESCRIPCIÓN:
-- Este script crea los Stored Procedures en el esquema COMUN
-- para el módulo de Consulta de Trámites
-- CORREGIDO: Usa comun.tramites en lugar de public.tramites
-- =============================================

-- =============================================
-- 1. consulta_tramites_list
-- Búsqueda de trámites con filtros múltiples y paginación
-- =============================================

DROP FUNCTION IF EXISTS comun.consulta_tramites_list(
    INTEGER, VARCHAR, VARCHAR, DATE, DATE, VARCHAR, VARCHAR,
    INTEGER, INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER
);

CREATE OR REPLACE FUNCTION comun.consulta_tramites_list(
    p_id_tramite INTEGER DEFAULT NULL,
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
BEGIN
    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Contar total de registros
    SELECT COUNT(*) INTO v_total
    FROM comun.tramites t
    WHERE
        (p_id_tramite IS NULL OR t.id_tramite = p_id_tramite)
        AND (NULLIF(p_tipo_tramite, '') IS NULL OR t.tipo_tramite = p_tipo_tramite)
        AND (NULLIF(p_estatus, '') IS NULL OR t.estatus = p_estatus)
        AND (p_fecha_desde IS NULL OR t.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR t.feccap <= p_fecha_hasta)
        AND (NULLIF(p_propietario, '') IS NULL OR UPPER(TRIM(t.propietario)) LIKE '%' || UPPER(p_propietario) || '%')
        AND (NULLIF(p_rfc, '') IS NULL OR UPPER(TRIM(t.rfc)) LIKE '%' || UPPER(p_rfc) || '%')
        AND (p_id_giro IS NULL OR t.id_giro = p_id_giro)
        AND (NULLIF(p_calle, '') IS NULL OR UPPER(TRIM(t.ubicacion)) LIKE '%' || UPPER(p_calle) || '%')
        AND (NULLIF(p_colonia, '') IS NULL OR UPPER(TRIM(t.colonia_ubic)) LIKE '%' || UPPER(p_colonia) || '%');

    -- Retornar datos paginados
    RETURN QUERY
    SELECT DISTINCT ON (t.id_tramite)
        -- Datos principales
        t.id_tramite,
        t.folio,
        TRIM(t.tipo_tramite)::VARCHAR AS tipo_tramite,
        CASE TRIM(t.tipo_tramite)
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
        COALESCE(TRIM(t.actividad), 'Sin actividad')::VARCHAR AS actividad_desc,

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
        t.observaciones,
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
        AND (NULLIF(p_tipo_tramite, '') IS NULL OR t.tipo_tramite = p_tipo_tramite)
        AND (NULLIF(p_estatus, '') IS NULL OR t.estatus = p_estatus)
        AND (p_fecha_desde IS NULL OR t.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR t.feccap <= p_fecha_hasta)
        AND (NULLIF(p_propietario, '') IS NULL OR UPPER(TRIM(t.propietario)) LIKE '%' || UPPER(p_propietario) || '%')
        AND (NULLIF(p_rfc, '') IS NULL OR UPPER(TRIM(t.rfc)) LIKE '%' || UPPER(p_rfc) || '%')
        AND (p_id_giro IS NULL OR t.id_giro = p_id_giro)
        AND (NULLIF(p_calle, '') IS NULL OR UPPER(TRIM(t.ubicacion)) LIKE '%' || UPPER(p_calle) || '%')
        AND (NULLIF(p_colonia, '') IS NULL OR UPPER(TRIM(t.colonia_ubic)) LIKE '%' || UPPER(p_colonia) || '%')
    ORDER BY t.id_tramite DESC, t.feccap DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.consulta_tramites_list IS 'Lista trámites con filtros múltiples y paginación - Esquema comun - CORREGIDO';

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

    -- Si no hay trámites, evitar división por cero
    IF v_total_general = 0 THEN
        v_total_general := 1;
    END IF;

    -- Retornar TODOS los estatus posibles, incluso con 0 registros
    RETURN QUERY
    WITH todos_estatus AS (
        SELECT 'P'::VARCHAR AS cod_estatus, 'Pendiente'::VARCHAR AS desc_estatus, 1 AS orden
        UNION ALL SELECT 'E', 'En Revisión', 2
        UNION ALL SELECT 'V', 'En Visita', 3
        UNION ALL SELECT 'A', 'Autorizado', 4
        UNION ALL SELECT 'R', 'Rechazado', 5
        UNION ALL SELECT 'C', 'Cancelado', 6
    ),
    datos_reales AS (
        SELECT
            TRIM(t.estatus) AS estatus_real,
            COUNT(*)::INTEGER AS total_real
        FROM comun.tramites t
        WHERE TRIM(t.estatus) IN ('P', 'E', 'V', 'A', 'R', 'C')
        GROUP BY TRIM(t.estatus)
    )
    SELECT
        te.cod_estatus::VARCHAR,
        te.desc_estatus::VARCHAR,
        COALESCE(dr.total_real, 0)::INTEGER AS total,
        ROUND((COALESCE(dr.total_real, 0)::NUMERIC / v_total_general::NUMERIC * 100), 2) AS porcentaje
    FROM todos_estatus te
    LEFT JOIN datos_reales dr ON te.cod_estatus = dr.estatus_real
    ORDER BY te.orden;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.consulta_tramites_estadisticas IS 'Estadísticas de trámites por estatus - Esquema comun - CORREGIDO';

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
        RAISE NOTICE '✓ comun.consulta_tramites_list creado correctamente';
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
    RAISE NOTICE '================================================';
END $$;

-- =============================================
-- EJEMPLOS DE USO
-- =============================================

-- Ejemplo 1: Buscar todos los trámites (primera página, 20 registros)
-- SELECT * FROM comun.consulta_tramites_list(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 2: Buscar trámites pendientes
-- SELECT * FROM comun.consulta_tramites_list(NULL, NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 3: Buscar por propietario
-- SELECT * FROM comun.consulta_tramites_list(NULL, NULL, NULL, NULL, NULL, 'LOPEZ', NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 4: Buscar por rango de fechas
-- SELECT * FROM comun.consulta_tramites_list(NULL, NULL, NULL, '2024-01-01', '2024-12-31', NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 5: Obtener estadísticas
-- SELECT * FROM comun.consulta_tramites_estadisticas();

-- =============================================
-- FIN DEL SCRIPT
-- =============================================
