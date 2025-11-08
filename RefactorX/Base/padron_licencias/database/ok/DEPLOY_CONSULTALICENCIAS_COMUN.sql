-- ============================================================================
-- DEPLOY: Stored Procedures para Consulta de Licencias
-- Schema: comun
-- Database: padron_licencias
-- Fecha: 2025-11-04
-- Descripción: SPs para búsqueda y estadísticas de licencias
-- ============================================================================

-- Drop functions if exist (para permitir re-deploy)
DROP FUNCTION IF EXISTS comun.consulta_licencias_list(INTEGER, INTEGER, VARCHAR, DATE, DATE, VARCHAR, VARCHAR, INTEGER, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS comun.consulta_licencias_estadisticas();

-- ============================================================================
-- FUNCTION: consulta_licencias_list
-- Descripción: Búsqueda de licencias con filtros múltiples y paginación
-- Retorna: Lista de licencias con información detallada
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.consulta_licencias_list(
    -- Filtros de búsqueda
    p_id_licencia INTEGER DEFAULT NULL,
    p_licencia INTEGER DEFAULT NULL,
    p_vigente VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_rfc VARCHAR DEFAULT NULL,
    p_id_giro INTEGER DEFAULT NULL,
    p_actividad VARCHAR DEFAULT NULL,
    p_ubicacion VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL,
    -- Paginación
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    -- Campos principales
    id_licencia INTEGER,
    licencia INTEGER,
    vigente VARCHAR,
    fecha_otorgamiento DATE,

    -- Información del propietario
    propietario VARCHAR,
    primer_ap VARCHAR,
    segundo_ap VARCHAR,
    rfc VARCHAR,
    curp VARCHAR,
    telefono_prop VARCHAR,
    email VARCHAR,

    -- Domicilio del propietario
    domicilio VARCHAR,
    numext_prop INTEGER,
    numint_prop VARCHAR,
    colonia_prop VARCHAR,

    -- Ubicación del negocio
    ubicacion VARCHAR,
    numext_ubic INTEGER,
    numint_ubic VARCHAR,
    colonia_ubic VARCHAR,

    -- Información del giro
    id_giro INTEGER,
    descripcion_giro VARCHAR,
    actividad VARCHAR,

    -- Información técnica
    sup_construida NUMERIC,
    sup_autorizada NUMERIC,
    num_empleados SMALLINT,
    aforo SMALLINT,
    inversion NUMERIC,
    rhorario VARCHAR,

    -- Control
    bloqueado SMALLINT,
    fecha_baja DATE,

    -- Total de registros
    total_registros BIGINT
) AS $$
DECLARE
    v_offset INTEGER;
BEGIN
    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Retornar datos paginados
    RETURN QUERY
    SELECT DISTINCT ON (l.id_licencia)
        -- Datos principales
        l.id_licencia,
        l.licencia,
        TRIM(l.vigente)::VARCHAR,
        l.fecha_otorgamiento,

        -- Propietario
        TRIM(l.propietario)::VARCHAR,
        TRIM(l.primer_ap)::VARCHAR,
        TRIM(l.segundo_ap)::VARCHAR,
        TRIM(l.rfc)::VARCHAR,
        TRIM(l.curp)::VARCHAR,
        TRIM(l.telefono_prop)::VARCHAR,
        TRIM(l.email)::VARCHAR,

        -- Domicilio propietario
        TRIM(l.domicilio)::VARCHAR,
        l.numext_prop,
        TRIM(l.numint_prop)::VARCHAR,
        TRIM(l.colonia_prop)::VARCHAR,

        -- Ubicación negocio
        TRIM(l.ubicacion)::VARCHAR,
        l.numext_ubic,
        TRIM(l.numint_ubic)::VARCHAR,
        TRIM(l.colonia_ubic)::VARCHAR,

        -- Giro
        l.id_giro,
        TRIM(g.descripcion)::VARCHAR,
        TRIM(l.actividad)::VARCHAR,

        -- Info técnica
        l.sup_construida,
        l.sup_autorizada,
        l.num_empleados,
        l.aforo,
        l.inversion,
        TRIM(l.rhorario)::VARCHAR,

        -- Control
        l.bloqueado,
        l.fecha_baja,

        -- Total de registros (subconsulta para contar)
        (
            SELECT COUNT(DISTINCT l2.id_licencia)
            FROM comun.licencias l2
            LEFT JOIN comun.c_giros g2 ON g2.id_giro = l2.id_giro
            WHERE
                -- Aplicar los mismos filtros que en la consulta principal
                (p_id_licencia IS NULL OR l2.id_licencia = p_id_licencia)
                AND (p_licencia IS NULL OR l2.licencia = p_licencia)
                AND (NULLIF(p_vigente, '') IS NULL OR UPPER(TRIM(l2.vigente)) = UPPER(p_vigente))
                AND (p_fecha_desde IS NULL OR l2.fecha_otorgamiento >= p_fecha_desde)
                AND (p_fecha_hasta IS NULL OR l2.fecha_otorgamiento <= p_fecha_hasta)
                AND (NULLIF(p_propietario, '') IS NULL OR UPPER(TRIM(l2.propietario)) LIKE '%' || UPPER(p_propietario) || '%')
                AND (NULLIF(p_rfc, '') IS NULL OR UPPER(TRIM(l2.rfc)) LIKE '%' || UPPER(p_rfc) || '%')
                AND (p_id_giro IS NULL OR l2.id_giro = p_id_giro)
                AND (NULLIF(p_actividad, '') IS NULL OR UPPER(TRIM(l2.actividad)) LIKE '%' || UPPER(p_actividad) || '%')
                AND (NULLIF(p_ubicacion, '') IS NULL OR UPPER(TRIM(l2.ubicacion)) LIKE '%' || UPPER(p_ubicacion) || '%')
                AND (NULLIF(p_colonia, '') IS NULL OR UPPER(TRIM(l2.colonia_ubic)) LIKE '%' || UPPER(p_colonia) || '%')
        )
    FROM comun.licencias l
    LEFT JOIN comun.c_giros g ON g.id_giro = l.id_giro
    WHERE
        -- Filtros de búsqueda (usar NULLIF para tratar '' como NULL)
        (p_id_licencia IS NULL OR l.id_licencia = p_id_licencia)
        AND (p_licencia IS NULL OR l.licencia = p_licencia)
        AND (NULLIF(p_vigente, '') IS NULL OR UPPER(TRIM(l.vigente)) = UPPER(p_vigente))
        AND (p_fecha_desde IS NULL OR l.fecha_otorgamiento >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR l.fecha_otorgamiento <= p_fecha_hasta)
        AND (NULLIF(p_propietario, '') IS NULL OR UPPER(TRIM(l.propietario)) LIKE '%' || UPPER(p_propietario) || '%')
        AND (NULLIF(p_rfc, '') IS NULL OR UPPER(TRIM(l.rfc)) LIKE '%' || UPPER(p_rfc) || '%')
        AND (p_id_giro IS NULL OR l.id_giro = p_id_giro)
        AND (NULLIF(p_actividad, '') IS NULL OR UPPER(TRIM(l.actividad)) LIKE '%' || UPPER(p_actividad) || '%')
        AND (NULLIF(p_ubicacion, '') IS NULL OR UPPER(TRIM(l.ubicacion)) LIKE '%' || UPPER(p_ubicacion) || '%')
        AND (NULLIF(p_colonia, '') IS NULL OR UPPER(TRIM(l.colonia_ubic)) LIKE '%' || UPPER(p_colonia) || '%')
    ORDER BY l.id_licencia DESC, l.fecha_otorgamiento DESC
    LIMIT p_limit
    OFFSET v_offset;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCTION: consulta_licencias_estadisticas
-- Descripción: Obtiene estadísticas de licencias por vigente
-- Retorna: Conteo y porcentaje de licencias por estatus
-- ============================================================================

CREATE OR REPLACE FUNCTION comun.consulta_licencias_estadisticas()
RETURNS TABLE (
    vigente VARCHAR,
    descripcion VARCHAR,
    total INTEGER,
    porcentaje NUMERIC
) AS $$
DECLARE
    v_total_general INTEGER;
BEGIN
    -- Calcular total general de licencias
    SELECT COUNT(*) INTO v_total_general
    FROM comun.licencias;

    -- Prevenir división por cero
    IF v_total_general = 0 THEN
        v_total_general := 1;
    END IF;

    -- Retornar estadísticas con todos los estatus posibles
    RETURN QUERY
    WITH todos_estatus AS (
        SELECT 'V'::VARCHAR AS cod_vigente, 'Vigente'::VARCHAR AS desc_vigente, 1 AS orden
        UNION ALL SELECT 'C', 'Cancelado', 2
        UNION ALL SELECT 'A', 'Alta', 3
        UNION ALL SELECT 'B', 'Baja', 4
    ),
    conteos AS (
        SELECT
            UPPER(TRIM(l.vigente)) AS vigente,
            COUNT(*)::INTEGER AS cantidad
        FROM comun.licencias l
        WHERE TRIM(l.vigente) IN ('V', 'C', 'A', 'B')
        GROUP BY UPPER(TRIM(l.vigente))
    )
    SELECT
        e.cod_vigente,
        e.desc_vigente,
        COALESCE(c.cantidad, 0) AS total,
        ROUND((COALESCE(c.cantidad, 0)::NUMERIC / v_total_general::NUMERIC) * 100, 2) AS porcentaje
    FROM todos_estatus e
    LEFT JOIN conteos c ON c.vigente = e.cod_vigente
    ORDER BY e.orden;

END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Mensajes de confirmación
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✓ comun.consulta_licencias_list creado correctamente';
    RAISE NOTICE '✓ comun.consulta_licencias_estadisticas creado correctamente';
    RAISE NOTICE '✓ Instalación completada exitosamente';
END $$;
