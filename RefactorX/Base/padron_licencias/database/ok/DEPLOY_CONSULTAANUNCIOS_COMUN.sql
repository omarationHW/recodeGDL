-- =============================================
-- DEPLOYMENT: Stored Procedures para Consulta de Anuncios
-- Módulo: Padron Licencias - consultaAnunciofrm.vue
-- Esquema: comun
-- Database: padron_licencias
-- Fecha: 2025-11-05
-- Autor: Sistema RefactorX
-- =============================================
-- DESCRIPCIÓN:
-- Este script crea los Stored Procedures en el esquema COMUN
-- de la base de datos padron_licencias
-- para el módulo de Consulta de Anuncios
-- =============================================

-- =============================================
-- 1. consulta_anuncios_list
-- Búsqueda de anuncios con filtros múltiples y paginación
-- =============================================

-- Eliminar versiones anteriores
DROP FUNCTION IF EXISTS comun.consulta_anuncios_list CASCADE;

CREATE OR REPLACE FUNCTION comun.consulta_anuncios_list(
    p_id_anuncio INTEGER DEFAULT NULL,
    p_anuncio INTEGER DEFAULT NULL,
    p_id_licencia INTEGER DEFAULT NULL,
    p_propietario VARCHAR DEFAULT NULL,
    p_ubicacion VARCHAR DEFAULT NULL,
    p_colonia VARCHAR DEFAULT NULL,
    p_zona SMALLINT DEFAULT NULL,
    p_vigente VARCHAR DEFAULT NULL,
    p_fecha_desde DATE DEFAULT NULL,
    p_fecha_hasta DATE DEFAULT NULL,
    p_id_giro INTEGER DEFAULT NULL,
    p_page INTEGER DEFAULT 1,
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    -- Datos principales del anuncio
    id_anuncio INTEGER,
    anuncio INTEGER,
    vigente VARCHAR,
    bloqueado SMALLINT,

    -- Datos del giro
    id_giro INTEGER,
    giro_desc VARCHAR,

    -- Datos de la licencia
    id_licencia INTEGER,
    licencia INTEGER,
    propietario VARCHAR,

    -- Ubicación
    ubicacion VARCHAR,
    espubic VARCHAR,
    numext_ubic INTEGER,
    letraext_ubic VARCHAR,
    numint_ubic VARCHAR,
    letraint_ubic VARCHAR,
    colonia_ubic VARCHAR,
    cp INTEGER,
    zona SMALLINT,
    subzona SMALLINT,

    -- Características del anuncio
    texto_anuncio VARCHAR,
    medidas1 NUMERIC,
    medidas2 NUMERIC,
    area_anuncio NUMERIC,
    num_caras SMALLINT,
    base_impuesto NUMERIC,
    misma_forma VARCHAR,
    asiento SMALLINT,

    -- Fechas
    fecha_otorgamiento DATE,
    fecha_baja DATE,
    axo_baja INTEGER,
    folio_baja INTEGER,

    -- Otros
    recaud SMALLINT,
    id_fabricante INTEGER,
    cvecalle INTEGER,

    -- Paginación
    total_records INTEGER
) AS $$
DECLARE
    v_offset INTEGER;
    v_total INTEGER;
    -- Convertir cadenas vacías a NULL (Vue envía "" en lugar de null)
    v_propietario VARCHAR;
    v_ubicacion VARCHAR;
    v_colonia VARCHAR;
    v_vigente VARCHAR;
BEGIN
    -- Convertir cadenas vacías a NULL usando NULLIF
    v_propietario := NULLIF(TRIM(p_propietario), '');
    v_ubicacion := NULLIF(TRIM(p_ubicacion), '');
    v_colonia := NULLIF(TRIM(p_colonia), '');
    v_vigente := NULLIF(TRIM(p_vigente), '');

    -- Calcular offset para paginación
    v_offset := (p_page - 1) * p_limit;

    -- Contar total de registros
    SELECT COUNT(DISTINCT a.id_anuncio) INTO v_total
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON l.id_licencia = a.id_licencia
    WHERE
        (p_id_anuncio IS NULL OR a.id_anuncio = p_id_anuncio)
        AND (p_anuncio IS NULL OR a.anuncio = p_anuncio)
        AND (p_id_licencia IS NULL OR a.id_licencia = p_id_licencia)
        AND (v_propietario IS NULL OR UPPER(l.propietario) LIKE '%' || UPPER(v_propietario) || '%')
        AND (v_ubicacion IS NULL OR
             UPPER(a.ubicacion) LIKE '%' || UPPER(v_ubicacion) || '%' OR
             UPPER(a.espubic) LIKE '%' || UPPER(v_ubicacion) || '%')
        AND (v_colonia IS NULL OR UPPER(a.colonia_ubic) LIKE '%' || UPPER(v_colonia) || '%')
        AND (p_zona IS NULL OR a.zona = p_zona)
        AND (v_vigente IS NULL OR a.vigente = v_vigente)
        AND (p_fecha_desde IS NULL OR a.fecha_otorgamiento >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR a.fecha_otorgamiento <= p_fecha_hasta)
        AND (p_id_giro IS NULL OR a.id_giro = p_id_giro);

    -- Retornar datos paginados (DISTINCT ON para evitar duplicados por JOINs)
    RETURN QUERY
    SELECT DISTINCT ON (a.id_anuncio)
        -- Datos principales
        a.id_anuncio,
        a.anuncio,
        TRIM(a.vigente)::VARCHAR AS vigente,
        a.bloqueado,

        -- Giro
        a.id_giro,
        COALESCE(TRIM(g.descripcion), 'Sin giro')::VARCHAR AS giro_desc,

        -- Licencia y propietario
        a.id_licencia,
        l.licencia,
        TRIM(l.propietario)::VARCHAR AS propietario,

        -- Ubicación
        TRIM(a.ubicacion)::VARCHAR AS ubicacion,
        TRIM(a.espubic)::VARCHAR AS espubic,
        a.numext_ubic,
        TRIM(a.letraext_ubic)::VARCHAR AS letraext_ubic,
        TRIM(a.numint_ubic)::VARCHAR AS numint_ubic,
        TRIM(a.letraint_ubic)::VARCHAR AS letraint_ubic,
        TRIM(a.colonia_ubic)::VARCHAR AS colonia_ubic,
        a.cp,
        a.zona,
        a.subzona,

        -- Características
        TRIM(a.texto_anuncio)::VARCHAR AS texto_anuncio,
        a.medidas1,
        a.medidas2,
        a.area_anuncio,
        a.num_caras,
        a.base_impuesto,
        TRIM(a.misma_forma)::VARCHAR AS misma_forma,
        a.asiento,

        -- Fechas
        a.fecha_otorgamiento,
        a.fecha_baja,
        a.axo_baja,
        a.folio_baja,

        -- Otros
        a.recaud,
        a.id_fabricante,
        a.cvecalle,

        -- Total registros
        v_total
    FROM comun.anuncios a
    LEFT JOIN comun.licencias l ON l.id_licencia = a.id_licencia
    LEFT JOIN comun.c_giros g ON g.id_giro = a.id_giro
    WHERE
        (p_id_anuncio IS NULL OR a.id_anuncio = p_id_anuncio)
        AND (p_anuncio IS NULL OR a.anuncio = p_anuncio)
        AND (p_id_licencia IS NULL OR a.id_licencia = p_id_licencia)
        AND (v_propietario IS NULL OR UPPER(l.propietario) LIKE '%' || UPPER(v_propietario) || '%')
        AND (v_ubicacion IS NULL OR
             UPPER(a.ubicacion) LIKE '%' || UPPER(v_ubicacion) || '%' OR
             UPPER(a.espubic) LIKE '%' || UPPER(v_ubicacion) || '%')
        AND (v_colonia IS NULL OR UPPER(a.colonia_ubic) LIKE '%' || UPPER(v_colonia) || '%')
        AND (p_zona IS NULL OR a.zona = p_zona)
        AND (v_vigente IS NULL OR a.vigente = v_vigente)
        AND (p_fecha_desde IS NULL OR a.fecha_otorgamiento >= p_fecha_desde)
        AND (p_fecha_hasta IS NULL OR a.fecha_otorgamiento <= p_fecha_hasta)
        AND (p_id_giro IS NULL OR a.id_giro = p_id_giro)
    ORDER BY a.id_anuncio DESC
    LIMIT p_limit
    OFFSET v_offset;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.consulta_anuncios_list IS 'Lista anuncios con filtros múltiples y paginación - Esquema comun - Base padron_licencias';

-- =============================================
-- 2. consulta_anuncios_estadisticas
-- Estadísticas de anuncios por vigencia
-- =============================================

DROP FUNCTION IF EXISTS comun.consulta_anuncios_estadisticas();

CREATE OR REPLACE FUNCTION comun.consulta_anuncios_estadisticas()
RETURNS TABLE (
    vigente VARCHAR,
    descripcion VARCHAR,
    total INTEGER,
    porcentaje NUMERIC
) AS $$
DECLARE
    v_total_general INTEGER;
BEGIN
    -- Obtener total general de anuncios
    SELECT COUNT(*) INTO v_total_general FROM comun.anuncios;

    -- Si no hay anuncios, retornar vacío
    IF v_total_general = 0 THEN
        v_total_general := 1; -- Evitar división por cero
    END IF;

    -- Retornar estadísticas por vigencia
    RETURN QUERY
    SELECT
        TRIM(a.vigente)::VARCHAR AS vigente,
        CASE TRIM(a.vigente)
            WHEN 'S' THEN 'Vigente'::VARCHAR
            WHEN 'N' THEN 'No Vigente'::VARCHAR
            WHEN 'C' THEN 'Cancelado'::VARCHAR
            ELSE 'Otro'::VARCHAR
        END AS descripcion,
        COUNT(*)::INTEGER AS total,
        ROUND((COUNT(*)::NUMERIC / v_total_general::NUMERIC * 100), 2) AS porcentaje
    FROM comun.anuncios a
    GROUP BY TRIM(a.vigente)
    ORDER BY COUNT(*) DESC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.consulta_anuncios_estadisticas IS 'Estadísticas de anuncios por vigencia - Esquema comun - Base padron_licencias';

-- =============================================
-- VERIFICACIÓN DE INSTALACIÓN
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Verificando instalación de Stored Procedures...';
    RAISE NOTICE '================================================';

    -- Verificar consulta_anuncios_list
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'consulta_anuncios_list'
    ) THEN
        RAISE NOTICE '✓ comun.consulta_anuncios_list creado correctamente (13 parámetros)';
    ELSE
        RAISE EXCEPTION '✗ Error: comun.consulta_anuncios_list no se creó';
    END IF;

    -- Verificar consulta_anuncios_estadisticas
    IF EXISTS (
        SELECT 1 FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'comun'
        AND p.proname = 'consulta_anuncios_estadisticas'
    ) THEN
        RAISE NOTICE '✓ comun.consulta_anuncios_estadisticas creado correctamente';
    ELSE
        RAISE EXCEPTION '✗ Error: comun.consulta_anuncios_estadisticas no se creó';
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

-- Ejemplo 1: Buscar todos los anuncios vigentes
-- SELECT * FROM comun.consulta_anuncios_list(NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'S', NULL, NULL, NULL, 1, 20);

-- Ejemplo 2: Buscar por número de anuncio
-- SELECT * FROM comun.consulta_anuncios_list(NULL, 14655, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 3: Buscar por propietario
-- SELECT * FROM comun.consulta_anuncios_list(NULL, NULL, NULL, 'COMERCIAL', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 4: Buscar por ubicación
-- SELECT * FROM comun.consulta_anuncios_list(NULL, NULL, NULL, NULL, 'LOPEZ', NULL, NULL, NULL, NULL, NULL, NULL, 1, 20);

-- Ejemplo 5: Obtener estadísticas
-- SELECT * FROM comun.consulta_anuncios_estadisticas();

-- =============================================
-- FIN DEL SCRIPT
-- =============================================
