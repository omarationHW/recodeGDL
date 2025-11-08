-- ============================================
-- STORED PROCEDURES FOR INFORMIX COMPATIBILITY
-- Component: LicenciasVigentesfrm.vue
-- Base: padron_licencias
-- Description: Procedures for active licenses management
-- ============================================

-- ============================================
-- POSTGRESQL VERSION - sp_licencias_vigentes
-- Compatible with frontend JSON parameter format
-- ============================================

-- Drop procedure if exists
DROP FUNCTION IF EXISTS informix.sp_licencias_vigentes(text);

-- Create PostgreSQL compatible function in informix schema
CREATE OR REPLACE FUNCTION informix.sp_licencias_vigentes(p_filtro text)
RETURNS TABLE (
    id integer,
    numero_licencia varchar(50),
    propietario varchar(255),
    actividad varchar(255),
    giro varchar(255),
    direccion varchar(500),
    colonia varchar(255),
    zona integer,
    fecha_vigencia_inicio date,
    fecha_vigencia_fin date,
    estado varchar(20),
    total_registros bigint
) AS $$
DECLARE
    v_filtros json;
    v_busqueda text;
    v_giro integer;
    v_anio integer;
    v_zona integer;
    v_limite integer;
    v_offset integer;
    v_vigencia text;
    v_total_count bigint;
    v_sql text;
    v_where_conditions text[];
BEGIN
    -- Parse JSON parameters with error handling
    BEGIN
        v_filtros := p_filtro::json;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Invalid JSON parameter: %', p_filtro;
    END;

    -- Extract parameters from JSON with defaults
    v_busqueda := COALESCE(v_filtros->>'busqueda', NULL);
    v_giro := CASE WHEN v_filtros->>'giro' IS NOT NULL AND v_filtros->>'giro' != ''
                   THEN (v_filtros->>'giro')::integer
                   ELSE NULL END;
    v_anio := CASE WHEN v_filtros->>'anio' IS NOT NULL AND v_filtros->>'anio' != ''
                   THEN (v_filtros->>'anio')::integer
                   ELSE NULL END;
    v_zona := CASE WHEN v_filtros->>'zona' IS NOT NULL AND v_filtros->>'zona' != ''
                   THEN (v_filtros->>'zona')::integer
                   ELSE NULL END;
    v_limite := COALESCE((v_filtros->>'limite')::integer, 25);
    v_offset := COALESCE((v_filtros->>'offset')::integer, 0);
    v_vigencia := COALESCE(v_filtros->>'vigencia', 'todas');

    -- Build WHERE conditions dynamically
    v_where_conditions := ARRAY[
        'l.vigente IN (''V'', ''C'')' -- Only valid and conditional licenses
    ];

    -- Add search filter
    IF v_busqueda IS NOT NULL AND trim(v_busqueda) != '' THEN
        v_where_conditions := v_where_conditions ||
            format('(l.licencia ILIKE %L OR l.propietario ILIKE %L)',
                   '%' || v_busqueda || '%', '%' || v_busqueda || '%');
    END IF;

    -- Add giro filter
    IF v_giro IS NOT NULL THEN
        v_where_conditions := v_where_conditions || format('l.id_giro = %s', v_giro);
    END IF;

    -- Add zona filter
    IF v_zona IS NOT NULL THEN
        v_where_conditions := v_where_conditions || format('l.zona = %s', v_zona);
    END IF;

    -- Add year filter (check both grant and expiration dates)
    IF v_anio IS NOT NULL THEN
        v_where_conditions := v_where_conditions ||
            format('(EXTRACT(YEAR FROM l.fecha_otorgamiento) = %s OR EXTRACT(YEAR FROM l.fecha_vencimiento) = %s)',
                   v_anio, v_anio);
    END IF;

    -- Get total count first
    v_sql := format('
        SELECT COUNT(*)
        FROM licencias l
        INNER JOIN c_giros g ON l.id_giro = g.id_giro
        WHERE %s',
        array_to_string(v_where_conditions, ' AND ')
    );

    EXECUTE v_sql INTO v_total_count;

    -- Return paginated results
    RETURN QUERY EXECUTE format('
        SELECT
            l.id_licencia,
            l.licencia,
            TRIM(COALESCE(l.propietario, '''') || '' '' || COALESCE(l.primer_ap, '''') || '' '' || COALESCE(l.segundo_ap, '''')),
            l.actividad,
            g.descripcion,
            TRIM(COALESCE(l.ubicacion, '''') || '' '' || COALESCE(l.numext_ubic::text, '''') || '' '' || COALESCE(l.letraext_ubic, '''')),
            l.colonia_ubic,
            l.zona,
            l.fecha_otorgamiento,
            l.fecha_vencimiento,
            CASE
                WHEN l.vigente = ''V'' THEN ''VIGENTE''
                WHEN l.vigente = ''C'' THEN ''CONDICIONADA''
                WHEN l.vigente = ''S'' THEN ''SUSPENDIDA''
                ELSE ''OTRO''
            END,
            %s::bigint
        FROM licencias l
        INNER JOIN c_giros g ON l.id_giro = g.id_giro
        WHERE %s
        ORDER BY l.licencia
        LIMIT %s OFFSET %s',
        v_total_count,
        array_to_string(v_where_conditions, ' AND '),
        v_limite,
        v_offset
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in sp_licencias_vigentes: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions
GRANT EXECUTE ON FUNCTION informix.sp_licencias_vigentes(text) TO public;

-- ============================================
-- ADDITIONAL POSTGRESQL PROCEDURES
-- Supporting procedures for the frontend
-- ============================================

-- Create informix schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS informix;

-- sp_giros_list - PostgreSQL version
DROP FUNCTION IF EXISTS informix.sp_giros_list();
CREATE OR REPLACE FUNCTION informix.sp_giros_list()
RETURNS TABLE (
    id integer,
    nombre varchar(255),
    clasificacion varchar(10),
    activo char(1)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id_giro,
        g.descripcion,
        COALESCE(g.clasificacion, 'GEN'::varchar(10)),
        COALESCE(g.activo, 'S'::char(1))
    FROM c_giros g
    WHERE COALESCE(g.activo, 'S') = 'S'
    ORDER BY g.descripcion;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION informix.sp_giros_list() TO public;

-- sp_zonas_list - PostgreSQL version
DROP FUNCTION IF EXISTS informix.sp_zonas_list();
CREATE OR REPLACE FUNCTION informix.sp_zonas_list()
RETURNS TABLE (
    id integer,
    nombre varchar(255),
    descripcion varchar(500)
) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        l.zona,
        ('Zona ' || l.zona::text)::varchar(255),
        ('Zona comercial ' || l.zona::text)::varchar(500)
    FROM licencias l
    WHERE l.zona IS NOT NULL
      AND l.zona > 0
    ORDER BY l.zona;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION informix.sp_zonas_list() TO public;

-- sp_generar_licencia_pdf - PostgreSQL version (placeholder)
DROP FUNCTION IF EXISTS informix.sp_generar_licencia_pdf(integer);
CREATE OR REPLACE FUNCTION informix.sp_generar_licencia_pdf(p_licencia_id integer)
RETURNS TABLE (
    archivo_pdf varchar(255),
    status varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ('licencia_' || p_licencia_id::text || '.pdf')::varchar(255),
        'SUCCESS'::varchar(50);
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION informix.sp_generar_licencia_pdf(integer) TO public;

-- sp_renovar_licencia - PostgreSQL version (placeholder)
DROP FUNCTION IF EXISTS informix.sp_renovar_licencia(integer);
CREATE OR REPLACE FUNCTION informix.sp_renovar_licencia(p_licencia_id integer)
RETURNS TABLE (
    status varchar(50),
    mensaje varchar(255)
) AS $$
DECLARE
    v_nueva_fecha date;
    v_affected_rows integer;
BEGIN
    -- Calculate new expiration date (add 1 year)
    v_nueva_fecha := CURRENT_DATE + INTERVAL '1 year';

    -- Update license expiration date
    UPDATE licencias
    SET fecha_vencimiento = v_nueva_fecha,
        vigente = 'V'
    WHERE id_licencia = p_licencia_id;

    GET DIAGNOSTICS v_affected_rows = ROW_COUNT;

    IF v_affected_rows > 0 THEN
        RETURN QUERY
        SELECT
            'SUCCESS'::varchar(50),
            ('Licencia renovada exitosamente hasta ' || v_nueva_fecha::text)::varchar(255);
    ELSE
        RETURN QUERY
        SELECT
            'ERROR'::varchar(50),
            'Error al renovar la licencia'::varchar(255);
    END IF;
END;
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION informix.sp_renovar_licencia(integer) TO public;

-- ============================================
-- ORIGINAL INFORMIX PROCEDURES (PRESERVED)
-- ============================================

-- 1. sp_licencias_vigentes_list - Main procedure for listing active licenses
DROP PROCEDURE IF EXISTS sp_licencias_vigentes_list;

CREATE PROCEDURE sp_licencias_vigentes_list(
    p_busqueda VARCHAR(255),
    p_giro INTEGER,
    p_anio INTEGER,
    p_zona INTEGER,
    p_limite INTEGER,
    p_offset INTEGER
)
RETURNING
    INTEGER AS id,
    VARCHAR(50) AS numero_licencia,
    VARCHAR(255) AS propietario,
    VARCHAR(255) AS actividad,
    VARCHAR(255) AS giro,
    VARCHAR(500) AS direccion,
    VARCHAR(255) AS colonia,
    INTEGER AS zona,
    DATE AS fecha_vigencia_inicio,
    DATE AS fecha_vigencia_fin,
    VARCHAR(20) AS estado,
    INTEGER AS total_registros;

    DEFINE v_id INTEGER;
    DEFINE v_numero_licencia VARCHAR(50);
    DEFINE v_propietario VARCHAR(255);
    DEFINE v_actividad VARCHAR(255);
    DEFINE v_giro VARCHAR(255);
    DEFINE v_direccion VARCHAR(500);
    DEFINE v_colonia VARCHAR(255);
    DEFINE v_zona INTEGER;
    DEFINE v_fecha_inicio DATE;
    DEFINE v_fecha_fin DATE;
    DEFINE v_estado VARCHAR(20);
    DEFINE v_total INTEGER;
    DEFINE v_sql_where VARCHAR(1000);
    DEFINE v_year_inicio INTEGER;
    DEFINE v_year_fin INTEGER;

    -- Calculate year range for vigencia filter
    IF p_anio IS NOT NULL THEN
        LET v_year_inicio = p_anio;
        LET v_year_fin = p_anio;
    END IF;

    -- Count total records first
    SELECT COUNT(*)
    INTO v_total
    FROM licencias l
    INNER JOIN c_giros g ON l.id_giro = g.id_giro
    WHERE l.vigente IN ('V', 'C') -- Vigente o Condicionada
      AND (p_busqueda IS NULL OR
           l.licencia LIKE '%' || p_busqueda || '%' OR
           l.propietario LIKE '%' || p_busqueda || '%')
      AND (p_giro IS NULL OR l.id_giro = p_giro)
      AND (p_zona IS NULL OR l.zona = p_zona)
      AND (p_anio IS NULL OR
           YEAR(l.fecha_otorgamiento) = p_anio OR
           YEAR(l.fecha_vencimiento) = p_anio);

    -- Return paginated results
    FOREACH SELECT
        l.id_licencia,
        l.licencia,
        TRIM(l.propietario || ' ' || NVL(l.primer_ap, '') || ' ' || NVL(l.segundo_ap, '')),
        l.actividad,
        g.descripcion,
        TRIM(l.ubicacion || ' ' || NVL(l.numext_ubic, '') || ' ' || NVL(l.letraext_ubic, '')),
        l.colonia_ubic,
        l.zona,
        l.fecha_otorgamiento,
        l.fecha_vencimiento,
        CASE
            WHEN l.vigente = 'V' THEN 'VIGENTE'
            WHEN l.vigente = 'C' THEN 'CONDICIONADA'
            WHEN l.vigente = 'S' THEN 'SUSPENDIDA'
            ELSE 'OTRO'
        END
    INTO
        v_id, v_numero_licencia, v_propietario, v_actividad, v_giro,
        v_direccion, v_colonia, v_zona, v_fecha_inicio, v_fecha_fin, v_estado
    FROM licencias l
    INNER JOIN c_giros g ON l.id_giro = g.id_giro
    WHERE l.vigente IN ('V', 'C')
      AND (p_busqueda IS NULL OR
           l.licencia LIKE '%' || p_busqueda || '%' OR
           l.propietario LIKE '%' || p_busqueda || '%')
      AND (p_giro IS NULL OR l.id_giro = p_giro)
      AND (p_zona IS NULL OR l.zona = p_zona)
      AND (p_anio IS NULL OR
           YEAR(l.fecha_otorgamiento) = p_anio OR
           YEAR(l.fecha_vencimiento) = p_anio)
    ORDER BY l.licencia
    SKIP p_offset
    FIRST p_limite

        RETURN v_id, v_numero_licencia, v_propietario, v_actividad, v_giro,
               v_direccion, v_colonia, v_zona, v_fecha_inicio, v_fecha_fin, v_estado, v_total
        WITH RESUME;

    END FOREACH;

END PROCEDURE;

-- ============================================

-- 2. sp_giros_list - Get list of business activities
DROP PROCEDURE IF EXISTS sp_giros_list;

CREATE PROCEDURE sp_giros_list()
RETURNING
    INTEGER AS id,
    VARCHAR(255) AS nombre,
    VARCHAR(10) AS clasificacion,
    CHAR(1) AS activo;

    DEFINE v_id INTEGER;
    DEFINE v_nombre VARCHAR(255);
    DEFINE v_clasificacion VARCHAR(10);
    DEFINE v_activo CHAR(1);

    FOREACH SELECT
        id_giro,
        descripcion,
        clasificacion,
        'S' -- Asumiendo que todos están activos
    INTO v_id, v_nombre, v_clasificacion, v_activo
    FROM c_giros
    WHERE activo = 'S' OR activo IS NULL
    ORDER BY descripcion

        RETURN v_id, v_nombre, v_clasificacion, v_activo WITH RESUME;

    END FOREACH;

END PROCEDURE;

-- ============================================

-- 3. sp_zonas_list - Get list of zones
DROP PROCEDURE IF EXISTS sp_zonas_list;

CREATE PROCEDURE sp_zonas_list()
RETURNING
    INTEGER AS id,
    VARCHAR(255) AS nombre,
    VARCHAR(500) AS descripcion;

    DEFINE v_id INTEGER;
    DEFINE v_nombre VARCHAR(255);
    DEFINE v_descripcion VARCHAR(500);

    FOREACH SELECT DISTINCT
        zona,
        'Zona ' || zona,
        'Zona comercial ' || zona
    INTO v_id, v_nombre, v_descripcion
    FROM licencias
    WHERE zona IS NOT NULL
      AND zona > 0
    ORDER BY zona

        RETURN v_id, v_nombre, v_descripcion WITH RESUME;

    END FOREACH;

END PROCEDURE;

-- ============================================

-- 4. sp_generar_licencia_pdf - Generate license PDF (placeholder)
DROP PROCEDURE IF EXISTS sp_generar_licencia_pdf;

CREATE PROCEDURE sp_generar_licencia_pdf(p_licencia_id INTEGER)
RETURNING
    VARCHAR(255) AS archivo_pdf,
    VARCHAR(50) AS status;

    RETURN 'licencia_' || p_licencia_id || '.pdf', 'SUCCESS' WITH RESUME;

END PROCEDURE;

-- ============================================

-- 5. sp_renovar_licencia - Renew license (placeholder)
DROP PROCEDURE IF EXISTS sp_renovar_licencia;

CREATE PROCEDURE sp_renovar_licencia(p_licencia_id INTEGER)
RETURNING
    VARCHAR(50) AS status,
    VARCHAR(255) AS mensaje;

    DEFINE v_nueva_fecha DATE;

    -- Calculate new expiration date (add 1 year)
    LET v_nueva_fecha = TODAY + 365;

    -- Update license expiration date
    UPDATE licencias
    SET fecha_vencimiento = v_nueva_fecha,
        vigente = 'V'
    WHERE id_licencia = p_licencia_id;

    IF SQLCA.SQLCODE = 0 THEN
        RETURN 'SUCCESS', 'Licencia renovada exitosamente hasta ' || v_nueva_fecha WITH RESUME;
    ELSE
        RETURN 'ERROR', 'Error al renovar la licencia' WITH RESUME;
    END IF;

END PROCEDURE;