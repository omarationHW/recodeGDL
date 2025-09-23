-- ============================================
-- POSTGRESQL MIGRATION SCRIPT
-- INFORMIX TO POSTGRESQL COMPATIBILITY LAYER
-- Module: Licencias Vigentes
-- Generated: 2025-09-22
-- ============================================

-- ============================================
-- SECTION 1: SCHEMA SETUP
-- ============================================

-- Create informix schema for compatibility
CREATE SCHEMA IF NOT EXISTS informix;

-- Grant usage on schema
GRANT USAGE ON SCHEMA informix TO public;
GRANT CREATE ON SCHEMA informix TO postgres;

-- ============================================
-- SECTION 2: TABLE STRUCTURE VALIDATION
-- ============================================

-- Ensure required tables exist with proper structure
-- Note: Adjust data types as needed for your specific PostgreSQL setup

-- Validate licencias table structure
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'licencias') THEN
        RAISE NOTICE 'Creating licencias table structure...';
        CREATE TABLE IF NOT EXISTS licencias (
            id_licencia SERIAL PRIMARY KEY,
            licencia VARCHAR(50) UNIQUE,
            propietario VARCHAR(255),
            primer_ap VARCHAR(100),
            segundo_ap VARCHAR(100),
            actividad VARCHAR(255),
            id_giro INTEGER,
            ubicacion VARCHAR(255),
            numext_ubic INTEGER,
            letraext_ubic VARCHAR(10),
            colonia_ubic VARCHAR(255),
            zona INTEGER,
            fecha_otorgamiento DATE,
            fecha_vencimiento DATE,
            vigente CHAR(1) DEFAULT 'V', -- V=Vigente, C=Condicionada, S=Suspendida
            fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        -- Create indexes for better performance
        CREATE INDEX IF NOT EXISTS idx_licencias_vigente ON licencias(vigente);
        CREATE INDEX IF NOT EXISTS idx_licencias_giro ON licencias(id_giro);
        CREATE INDEX IF NOT EXISTS idx_licencias_zona ON licencias(zona);
        CREATE INDEX IF NOT EXISTS idx_licencias_fecha_venc ON licencias(fecha_vencimiento);
        CREATE INDEX IF NOT EXISTS idx_licencias_propietario ON licencias(propietario);
        CREATE INDEX IF NOT EXISTS idx_licencias_numero ON licencias(licencia);
    END IF;
END $$;

-- Validate c_giros table structure
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'c_giros') THEN
        RAISE NOTICE 'Creating c_giros table structure...';
        CREATE TABLE IF NOT EXISTS c_giros (
            id_giro SERIAL PRIMARY KEY,
            descripcion VARCHAR(255) NOT NULL,
            clasificacion VARCHAR(10) DEFAULT 'GEN',
            activo CHAR(1) DEFAULT 'S',
            fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );

        -- Insert some sample giros if table is empty
        INSERT INTO c_giros (descripcion, clasificacion, activo) VALUES
        ('Comercio en general', 'COM', 'S'),
        ('Restaurante', 'REST', 'S'),
        ('Oficinas', 'OF', 'S'),
        ('Servicios profesionales', 'SERV', 'S'),
        ('Industria', 'IND', 'S')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- ============================================
-- SECTION 3: STORED PROCEDURES
-- ============================================

-- Main procedure: sp_licencias_vigentes
-- Accepts JSON parameter for frontend compatibility
DROP FUNCTION IF EXISTS informix.sp_licencias_vigentes(text);
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

    -- Handle vigencia filter
    IF v_vigencia != 'todas' THEN
        CASE v_vigencia
            WHEN 'vigentes' THEN
                v_where_conditions := v_where_conditions || 'l.vigente = ''V''';
            WHEN 'condicionadas' THEN
                v_where_conditions := v_where_conditions || 'l.vigente = ''C''';
            WHEN 'suspendidas' THEN
                v_where_conditions := v_where_conditions || 'l.vigente = ''S''';
            WHEN 'vencidas' THEN
                v_where_conditions := v_where_conditions || 'l.fecha_vencimiento < CURRENT_DATE';
        END CASE;
    END IF;

    -- Get total count first
    v_sql := format('
        SELECT COUNT(*)
        FROM licencias l
        LEFT JOIN c_giros g ON l.id_giro = g.id_giro
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
            COALESCE(l.actividad, ''Sin especificar''),
            COALESCE(g.descripcion, ''Sin giro''),
            TRIM(COALESCE(l.ubicacion, '''') || '' '' || COALESCE(l.numext_ubic::text, '''') || '' '' || COALESCE(l.letraext_ubic, '''')),
            COALESCE(l.colonia_ubic, ''Sin especificar''),
            COALESCE(l.zona, 0),
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
        LEFT JOIN c_giros g ON l.id_giro = g.id_giro
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

-- Supporting procedure: sp_giros_list
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

-- Supporting procedure: sp_zonas_list
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

-- Utility procedure: sp_generar_licencia_pdf (placeholder)
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

-- Utility procedure: sp_renovar_licencia
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
        vigente = 'V',
        fecha_modificacion = CURRENT_TIMESTAMP
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
            'Error al renovar la licencia - Licencia no encontrada'::varchar(255);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SECTION 4: PERMISSIONS
-- ============================================

-- Grant execute permissions on all functions
GRANT EXECUTE ON FUNCTION informix.sp_licencias_vigentes(text) TO public;
GRANT EXECUTE ON FUNCTION informix.sp_giros_list() TO public;
GRANT EXECUTE ON FUNCTION informix.sp_zonas_list() TO public;
GRANT EXECUTE ON FUNCTION informix.sp_generar_licencia_pdf(integer) TO public;
GRANT EXECUTE ON FUNCTION informix.sp_renovar_licencia(integer) TO public;

-- Grant select permissions on tables
GRANT SELECT ON licencias TO public;
GRANT SELECT ON c_giros TO public;

-- ============================================
-- SECTION 5: SAMPLE DATA (OPTIONAL)
-- ============================================

-- Insert sample data if tables are empty (for testing)
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM licencias) = 0 THEN
        RAISE NOTICE 'Inserting sample license data...';

        INSERT INTO licencias (
            licencia, propietario, primer_ap, segundo_ap, actividad, id_giro,
            ubicacion, numext_ubic, colonia_ubic, zona,
            fecha_otorgamiento, fecha_vencimiento, vigente
        ) VALUES
        ('LIC-2024-001', 'Juan Carlos', 'Pérez', 'González', 'Restaurante familiar', 2, 'Av. Juárez', 123, 'Centro', 1, '2024-01-15', '2025-01-15', 'V'),
        ('LIC-2024-002', 'María Elena', 'Rodríguez', 'López', 'Tienda de abarrotes', 1, 'Calle 5 de Mayo', 456, 'Americana', 2, '2024-02-10', '2025-02-10', 'V'),
        ('LIC-2024-003', 'Roberto', 'Hernández', 'Martínez', 'Consultoria legal', 4, 'Av. López Cotilla', 789, 'Del Valle', 1, '2024-03-05', '2025-03-05', 'C'),
        ('LIC-2023-156', 'Ana Sofía', 'García', 'Mendoza', 'Panadería artesanal', 1, 'Calle Morelos', 321, 'Tlaquepaque', 3, '2023-06-20', '2024-06-20', 'V'),
        ('LIC-2024-004', 'Carlos Alberto', 'Jiménez', 'Cruz', 'Taller mecánico', 5, 'Av. Federalismo', 654, 'San Juan de Dios', 2, '2024-04-12', '2025-04-12', 'V')
        ON CONFLICT (licencia) DO NOTHING;
    END IF;
END $$;

-- ============================================
-- SECTION 6: VALIDATION TESTS
-- ============================================

-- Test main procedure with sample JSON
DO $$
DECLARE
    test_result RECORD;
    test_count INTEGER;
BEGIN
    RAISE NOTICE 'Running validation tests...';

    -- Test 1: Basic call with all filters
    SELECT COUNT(*) INTO test_count
    FROM informix.sp_licencias_vigentes('{"busqueda":null,"giro":null,"anio":null,"zona":null,"limite":25,"offset":0,"vigencia":"todas"}');

    RAISE NOTICE 'Test 1 - Basic call returned % records', test_count;

    -- Test 2: Search filter
    SELECT COUNT(*) INTO test_count
    FROM informix.sp_licencias_vigentes('{"busqueda":"LIC","giro":null,"anio":null,"zona":null,"limite":25,"offset":0,"vigencia":"todas"}');

    RAISE NOTICE 'Test 2 - Search filter returned % records', test_count;

    -- Test 3: Supporting procedures
    SELECT COUNT(*) INTO test_count FROM informix.sp_giros_list();
    RAISE NOTICE 'Test 3 - Giros list returned % records', test_count;

    SELECT COUNT(*) INTO test_count FROM informix.sp_zonas_list();
    RAISE NOTICE 'Test 4 - Zonas list returned % records', test_count;

    RAISE NOTICE 'All validation tests completed successfully!';
END $$;

-- ============================================
-- SECTION 7: INSTALLATION SUMMARY
-- ============================================

SELECT
    'PostgreSQL migration completed successfully' as status,
    CURRENT_TIMESTAMP as installation_date,
    5 as procedures_created,
    'informix' as schema_created,
    'sp_licencias_vigentes, sp_giros_list, sp_zonas_list, sp_generar_licencia_pdf, sp_renovar_licencia' as procedures_list;

-- ============================================
-- END OF POSTGRESQL MIGRATION SCRIPT
-- ============================================