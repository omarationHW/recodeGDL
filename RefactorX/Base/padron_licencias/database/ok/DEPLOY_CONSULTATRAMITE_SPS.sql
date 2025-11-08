-- =============================================
-- DEPLOYMENT: Stored Procedures para Consulta de Trámites
-- Módulo: Padron Licencias - ConsultaTramitefrm.vue
-- Fecha: 2025-11-04
-- Autor: Sistema RefactorX
-- =============================================
-- DESCRIPCIÓN:
-- Este script crea los Stored Procedures necesarios para el módulo
-- de Consulta de Trámites con filtros múltiples y estadísticas
-- =============================================

-- =============================================
-- 1. SP_CONSULTATRAMITE_LIST
-- Búsqueda de trámites con filtros múltiples y paginación
-- =============================================

DROP FUNCTION IF EXISTS public.SP_CONSULTATRAMITE_LIST(
    INTEGER, VARCHAR, VARCHAR, DATE, DATE, VARCHAR, VARCHAR,
    INTEGER, INTEGER, VARCHAR, VARCHAR, INTEGER, INTEGER
);

CREATE OR REPLACE FUNCTION public.SP_CONSULTATRAMITE_LIST(
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
    FROM public.tramites t
    WHERE
        (p_id_tramite IS NULL OR t.id_tramite = p_id_tramite)
        AND (p_tipo_tramite IS NULL OR t.tipo_tramite = p_tipo_tramite)
        AND (p_estatus IS NULL OR t.estatus = p_estatus)
        AND (p_fecha_desde IS NULL OR t.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR t.feccap <= p_fecha_hasta)
        AND (p_propietario IS NULL OR UPPER(t.propietario) LIKE '%' || UPPER(p_propietario) || '%')
        AND (p_rfc IS NULL OR UPPER(t.rfc) LIKE '%' || UPPER(p_rfc) || '%')
        AND (p_id_giro IS NULL OR t.id_giro = p_id_giro)
        AND (p_calle IS NULL OR UPPER(t.ubicacion) LIKE '%' || UPPER(p_calle) || '%')
        AND (p_colonia IS NULL OR UPPER(t.colonia_ubic) LIKE '%' || UPPER(p_colonia) || '%');

    -- Retornar datos paginados
    RETURN QUERY
    SELECT
        -- Datos principales
        t.id_tramite,
        t.folio,
        t.tipo_tramite,
        CASE t.tipo_tramite
            WHEN 'LN' THEN 'Licencia Nueva'::VARCHAR
            WHEN 'RE' THEN 'Renovación'::VARCHAR
            WHEN 'CG' THEN 'Cambio de Giro'::VARCHAR
            WHEN 'TR' THEN 'Traspaso'::VARCHAR
            WHEN 'AN' THEN 'Anuncio'::VARCHAR
            ELSE 'Otro'::VARCHAR
        END AS tipo_tramite_desc,
        t.estatus,

        -- Propietario
        t.propietario,
        t.primer_ap,
        t.segundo_ap,
        t.rfc,
        t.curp,
        t.telefono_prop,
        t.email,

        -- Ubicación
        t.ubicacion AS calle,
        CAST(t.numext_ubic AS VARCHAR) AS numero,
        t.numint_ubic,
        t.colonia_ubic AS colonia,
        t.cp,

        -- Giro
        t.id_giro,
        COALESCE(g.nombre, 'Sin giro')::VARCHAR AS giro_desc,
        t.actividad,
        COALESCE(a.descripcion, t.actividad)::VARCHAR AS actividad_desc,

        -- Fechas
        t.feccap AS fecha_solicitud,
        (t.feccap + INTERVAL '30 days')::DATE AS fecha_limite,
        t.fecha_consejo,
        t.feccap,

        -- Otros
        t.capturista,
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
    FROM public.tramites t
    LEFT JOIN public.giros g ON g.id_giro = t.id_giro
    LEFT JOIN public.actividades a ON a.id_actividad = CAST(t.actividad AS INTEGER)
    WHERE
        (p_id_tramite IS NULL OR t.id_tramite = p_id_tramite)
        AND (p_tipo_tramite IS NULL OR t.tipo_tramite = p_tipo_tramite)
        AND (p_estatus IS NULL OR t.estatus = p_estatus)
        AND (p_fecha_desde IS NULL OR t.feccap >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR t.feccap <= p_fecha_hasta)
        AND (p_propietario IS NULL OR UPPER(t.propietario) LIKE '%' || UPPER(p_propietario) || '%')
        AND (p_rfc IS NULL OR UPPER(t.rfc) LIKE '%' || UPPER(p_rfc) || '%')
        AND (p_id_giro IS NULL OR t.id_giro = p_id_giro)
        AND (p_calle IS NULL OR UPPER(t.ubicacion) LIKE '%' || UPPER(p_calle) || '%')
        AND (p_colonia IS NULL OR UPPER(t.colonia_ubic) LIKE '%' || UPPER(p_colonia) || '%')
    ORDER BY t.id_tramite DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.SP_CONSULTATRAMITE_LIST IS 'Lista trámites con filtros múltiples y paginación para el módulo de Consulta de Trámites';

-- =============================================
-- 2. SP_CONSULTATRAMITE_ESTADISTICAS
-- Estadísticas de trámites por estatus
-- =============================================

DROP FUNCTION IF EXISTS public.SP_CONSULTATRAMITE_ESTADISTICAS();

CREATE OR REPLACE FUNCTION public.SP_CONSULTATRAMITE_ESTADISTICAS()
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
    SELECT COUNT(*) INTO v_total_general FROM public.tramites;

    -- Si no hay trámites, retornar vacío
    IF v_total_general = 0 THEN
        v_total_general := 1; -- Evitar división por cero
    END IF;

    -- Retornar estadísticas por estatus
    RETURN QUERY
    SELECT
        t.estatus,
        CASE t.estatus
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
    FROM public.tramites t
    GROUP BY t.estatus
    ORDER BY COUNT(*) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION public.SP_CONSULTATRAMITE_ESTADISTICAS IS 'Retorna estadísticas de trámites agrupadas por estatus con conteos y porcentajes';

-- =============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- =============================================

-- Verificar que los SPs se crearon correctamente
DO $$
BEGIN
    RAISE NOTICE 'Verificando instalación de Stored Procedures...';

    -- Verificar SP_CONSULTATRAMITE_LIST
    IF EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'sp_consultatramite_list'
    ) THEN
        RAISE NOTICE '✓ SP_CONSULTATRAMITE_LIST creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: SP_CONSULTATRAMITE_LIST no se creó';
    END IF;

    -- Verificar SP_CONSULTATRAMITE_ESTADISTICAS
    IF EXISTS (
        SELECT 1 FROM pg_proc
        WHERE proname = 'sp_consultatramite_estadisticas'
    ) THEN
        RAISE NOTICE '✓ SP_CONSULTATRAMITE_ESTADISTICAS creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: SP_CONSULTATRAMITE_ESTADISTICAS no se creó';
    END IF;

    RAISE NOTICE '✓ Instalación completada exitosamente';
END $$;

-- =============================================
-- EJEMPLOS DE USO
-- =============================================

-- Ejemplo 1: Buscar todos los trámites pendientes
-- SELECT * FROM public.SP_CONSULTATRAMITE_LIST(NULL, NULL, 'P', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 2: Buscar por propietario
-- SELECT * FROM public.SP_CONSULTATRAMITE_LIST(NULL, NULL, NULL, NULL, NULL, 'LOPEZ', NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 3: Buscar por rango de fechas
-- SELECT * FROM public.SP_CONSULTATRAMITE_LIST(NULL, NULL, NULL, '2024-01-01', '2024-12-31', NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 4: Obtener estadísticas
-- SELECT * FROM public.SP_CONSULTATRAMITE_ESTADISTICAS();

-- =============================================
-- FIN DEL SCRIPT
-- =============================================
