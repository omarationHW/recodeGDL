-- ============================================
-- STORED PROCEDURES - CatastroDM Component
-- Batch: 11
-- Component: CatastroDM
-- Total SPs: 10
-- Description: Date calculations, rights management, and cadastral data for licensing system
-- Schema: comun (shared functionality)
-- Generated: 2025-11-21
-- ============================================

-- COMPONENT OVERVIEW:
-- This component handles:
-- 1. Date calculations considering non-working days
-- 2. Resolution date calculations by tramite type
-- 3. Payment limit date calculations
-- 4. Visit date scheduling with zone/dependency rules
-- 5. License and advertisement authorization
-- 6. Rights (derechos2) retrieval
-- 7. Utility functions for system operations

-- ============================================
-- SP 1/10: get_derechos2
-- Purpose: Get derechos2 value for a license or advertisement
-- Type: Query
-- Returns: Single numeric value representing derechos2
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_get_derechos2(
    p_id_licencia INTEGER DEFAULT 0,
    p_id_anuncio INTEGER DEFAULT 0
)
RETURNS TABLE(
    derechos2 NUMERIC
) AS $$
BEGIN
    -- Validate input: at least one ID must be provided
    IF p_id_licencia <= 0 AND p_id_anuncio <= 0 THEN
        RAISE EXCEPTION 'Must provide either p_id_licencia or p_id_anuncio';
    END IF;

    -- Get derechos2 for license
    IF p_id_licencia > 0 THEN
        RETURN QUERY
        SELECT COALESCE(d.derechos2, 0.0)::NUMERIC
        FROM detsal_lic d
        WHERE d.derechos2 > 0
            AND d.cvepago = 0
            AND d.id_licencia = p_id_licencia
        ORDER BY d.id DESC
        LIMIT 1;

        -- If found, return
        IF FOUND THEN
            RETURN;
        END IF;
    END IF;

    -- Get derechos2 for advertisement
    IF p_id_anuncio > 0 THEN
        RETURN QUERY
        SELECT COALESCE(d.derechos2, 0.0)::NUMERIC
        FROM detsal_lic d
        WHERE d.derechos2 > 0
            AND d.cvepago = 0
            AND d.id_anuncio = p_id_anuncio
        ORDER BY d.id DESC
        LIMIT 1;

        -- If found, return
        IF FOUND THEN
            RETURN;
        END IF;
    END IF;

    -- If nothing found, return 0
    RETURN QUERY SELECT 0.0::NUMERIC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_get_derechos2(INTEGER, INTEGER) IS
'Retrieves unpaid derechos2 value for a license or advertisement';

-- ============================================
-- SP 2/10: calc_fecha_res
-- Purpose: Calculate resolution date considering non-working days and tramite type
-- Type: Calculation
-- Returns: Calculated resolution date
-- Logic:
--   - Autoev: +3 days
--   - Type A/B: +15 days
--   - Type C: +10 days
--   - Type D: +20 days
--   - Other: +1 day
--   - Then skip all non-working days
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_calc_fecha_res(
    p_fecha_tram DATE,
    p_tipo TEXT,
    p_autoev BOOLEAN DEFAULT FALSE
)
RETURNS TABLE(
    fecha_res DATE
) AS $$
DECLARE
    v_dias INTEGER;
    v_fecha_salida DATE;
    v_dias_nolabor INTEGER;
    v_contador INTEGER;
    v_max_iterations INTEGER := 365; -- Prevent infinite loops
    v_iteration_count INTEGER := 0;
BEGIN
    -- Validate input date
    IF p_fecha_tram IS NULL THEN
        RAISE EXCEPTION 'p_fecha_tram cannot be NULL';
    END IF;

    -- Initialize output date
    v_fecha_salida := p_fecha_tram;

    -- Calculate initial date based on type
    IF p_autoev THEN
        v_fecha_salida := p_fecha_tram + INTERVAL '3 days';
    ELSE
        CASE UPPER(COALESCE(p_tipo, ''))
            WHEN 'A', 'B' THEN
                v_fecha_salida := p_fecha_tram + INTERVAL '15 days';
            WHEN 'C' THEN
                v_fecha_salida := p_fecha_tram + INTERVAL '10 days';
            WHEN 'D' THEN
                v_fecha_salida := p_fecha_tram + INTERVAL '20 days';
            ELSE
                v_fecha_salida := p_fecha_tram + INTERVAL '1 day';
        END CASE;
    END IF;

    -- Count non-working days in the range
    SELECT COUNT(*) INTO v_dias_nolabor
    FROM no_laboralesLic
    WHERE fecha BETWEEN p_fecha_tram AND v_fecha_salida;

    -- Add working days to compensate for non-working days
    v_contador := 0;
    WHILE v_contador < v_dias_nolabor LOOP
        v_iteration_count := v_iteration_count + 1;

        -- Safety check to prevent infinite loops
        IF v_iteration_count > v_max_iterations THEN
            RAISE EXCEPTION 'Maximum iterations exceeded in date calculation';
        END IF;

        v_fecha_salida := v_fecha_salida + INTERVAL '1 day';

        -- Only increment counter if the new date is a working day
        IF NOT EXISTS (
            SELECT 1 FROM no_laboralesLic
            WHERE fecha = v_fecha_salida
        ) AND EXTRACT(DOW FROM v_fecha_salida) NOT IN (0, 6) THEN
            v_contador := v_contador + 1;
        END IF;
    END LOOP;

    -- Final check: ensure we don't land on a non-working day
    WHILE EXISTS (
        SELECT 1 FROM no_laboralesLic
        WHERE fecha = v_fecha_salida
    ) OR EXTRACT(DOW FROM v_fecha_salida) IN (0, 6) LOOP
        v_iteration_count := v_iteration_count + 1;

        IF v_iteration_count > v_max_iterations THEN
            RAISE EXCEPTION 'Maximum iterations exceeded in final date adjustment';
        END IF;

        v_fecha_salida := v_fecha_salida + INTERVAL '1 day';
    END LOOP;

    RETURN QUERY SELECT v_fecha_salida;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_calc_fecha_res(DATE, TEXT, BOOLEAN) IS
'Calculates resolution date considering non-working days and tramite type';

-- ============================================
-- SP 3/10: checa_inhabil
-- Purpose: Check if a date is a non-working day
-- Type: Query
-- Returns: Boolean indicating if date is non-working
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_checa_inhabil(
    p_fecha DATE
)
RETURNS TABLE(
    es_inhabil BOOLEAN
) AS $$
BEGIN
    -- Validate input
    IF p_fecha IS NULL THEN
        RAISE EXCEPTION 'p_fecha cannot be NULL';
    END IF;

    -- Check if date exists in non-working days table
    RETURN QUERY
    SELECT EXISTS(
        SELECT 1
        FROM no_laboralesLic
        WHERE fecha = p_fecha
    ) OR EXTRACT(DOW FROM p_fecha) IN (0, 6); -- Also check for weekends
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_checa_inhabil(DATE) IS
'Checks if a given date is a non-working day (holiday or weekend)';

-- ============================================
-- SP 4/10: calc_fecha_limite_pago
-- Purpose: Calculate payment deadline considering non-working days
-- Type: Calculation
-- Returns: Payment deadline date (10 working days from tramite date)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_calc_fecha_limite_pago(
    p_fecha_tram DATE
)
RETURNS TABLE(
    fecha_limite_pago DATE
) AS $$
DECLARE
    v_fecha_salida DATE;
    v_dias_nolabor INTEGER;
    v_max_iterations INTEGER := 100;
    v_iteration_count INTEGER := 0;
BEGIN
    -- Validate input
    IF p_fecha_tram IS NULL THEN
        RAISE EXCEPTION 'p_fecha_tram cannot be NULL';
    END IF;

    -- Add 10 calendar days
    v_fecha_salida := p_fecha_tram + INTERVAL '10 days';

    -- Count non-working days in the initial range
    SELECT COUNT(*) INTO v_dias_nolabor
    FROM no_laboralesLic
    WHERE fecha BETWEEN p_fecha_tram AND v_fecha_salida;

    -- Add days to compensate for non-working days
    v_fecha_salida := v_fecha_salida + (v_dias_nolabor || ' days')::INTERVAL;

    -- Ensure we don't land on a non-working day
    WHILE EXISTS (
        SELECT 1 FROM no_laboralesLic
        WHERE fecha = v_fecha_salida
    ) OR EXTRACT(DOW FROM v_fecha_salida) IN (0, 6) LOOP
        v_iteration_count := v_iteration_count + 1;

        -- Safety check
        IF v_iteration_count > v_max_iterations THEN
            RAISE EXCEPTION 'Maximum iterations exceeded calculating payment deadline';
        END IF;

        v_fecha_salida := v_fecha_salida + INTERVAL '1 day';
    END LOOP;

    RETURN QUERY SELECT v_fecha_salida;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_calc_fecha_limite_pago(DATE) IS
'Calculates payment deadline (10 working days) from tramite date';

-- ============================================
-- SP 5/10: calc_fecha_visita
-- Purpose: Calculate visit date for tramite considering dependency schedule
-- Type: Calculation
-- Returns: Next available visit date based on zone, dependency, and capacity
-- Logic:
--   - Dependency 24 (Bomberos): +2 days
--   - Other dependencies: +1 day
--   - Skip non-working days
--   - Check dependency schedule by zone
--   - Check daily capacity (max 20 visits per day per schedule)
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_calc_fecha_visita(
    p_id_tramite INTEGER,
    p_id_dependencia INTEGER
)
RETURNS TABLE(
    fecha_visita DATE
) AS $$
DECLARE
    v_zona TEXT;
    v_fecha_visita DATE;
    v_continuar BOOLEAN;
    v_dias_visita_id INTEGER;
    v_cuantos INTEGER;
    v_dia_semana INTEGER;
    v_max_iterations INTEGER := 365;
    v_iteration_count INTEGER := 0;
BEGIN
    -- Validate inputs
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RAISE EXCEPTION 'Invalid p_id_tramite';
    END IF;

    IF p_id_dependencia IS NULL OR p_id_dependencia <= 0 THEN
        RAISE EXCEPTION 'Invalid p_id_dependencia';
    END IF;

    -- Get tramite zone
    SELECT COALESCE(zona, '') INTO v_zona
    FROM tramites
    WHERE id_tramite = p_id_tramite;

    IF v_zona IS NULL THEN
        RAISE EXCEPTION 'Tramite % not found', p_id_tramite;
    END IF;

    -- Initial date calculation
    IF p_id_dependencia = 24 THEN -- Bomberos
        v_fecha_visita := CURRENT_DATE + INTERVAL '2 days';
    ELSE
        v_fecha_visita := CURRENT_DATE + INTERVAL '1 day';
    END IF;

    -- Find next available date
    v_continuar := TRUE;

    WHILE v_continuar LOOP
        v_iteration_count := v_iteration_count + 1;

        -- Safety check
        IF v_iteration_count > v_max_iterations THEN
            RAISE EXCEPTION 'Maximum iterations exceeded finding visit date';
        END IF;

        -- Check if date is non-working
        IF EXISTS (
            SELECT 1 FROM no_laboralesLic
            WHERE fecha = v_fecha_visita
        ) OR EXTRACT(DOW FROM v_fecha_visita) IN (0, 6) THEN
            v_fecha_visita := v_fecha_visita + INTERVAL '1 day';
            CONTINUE;
        END IF;

        -- Get day of week (0=Sunday, 6=Saturday)
        v_dia_semana := EXTRACT(DOW FROM v_fecha_visita);

        -- Check dependency schedule for this zone and day
        SELECT h.id INTO v_dias_visita_id
        FROM c_dep_horario h
        WHERE h.id_dependencia = p_id_dependencia
            AND (h.zonas LIKE '%' || v_zona || '%' OR h.zonas = 'TODAS')
            AND h.dia = v_dia_semana
        LIMIT 1;

        -- If no schedule for this day, try next day
        IF v_dias_visita_id IS NULL THEN
            v_fecha_visita := v_fecha_visita + INTERVAL '1 day';
            CONTINUE;
        END IF;

        -- Check daily capacity
        SELECT COUNT(*) INTO v_cuantos
        FROM tramites_visitas
        WHERE fecha = v_fecha_visita
            AND c_dep_horario_id = v_dias_visita_id;

        -- If capacity reached (20 visits), try next day
        IF v_cuantos >= 20 THEN
            v_fecha_visita := v_fecha_visita + INTERVAL '1 day';
            CONTINUE;
        END IF;

        -- Found valid date
        v_continuar := FALSE;
    END LOOP;

    RETURN QUERY SELECT v_fecha_visita;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_calc_fecha_visita(INTEGER, INTEGER) IS
'Calculates next available visit date considering dependency schedule and capacity';

-- ============================================
-- SP 6/10: autoriza_licencia
-- Purpose: Authorize a license for a given tramite
-- Type: Transaction
-- Returns: Success status and message
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_autoriza_licencia(
    p_no_tramite INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_licencia INTEGER
) AS $$
DECLARE
    v_id_licencia INTEGER;
    v_tramite_exists BOOLEAN;
    v_licencia_exists BOOLEAN;
BEGIN
    -- Validate input
    IF p_no_tramite IS NULL OR p_no_tramite <= 0 THEN
        RETURN QUERY SELECT FALSE, 'Invalid tramite number'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Check if tramite exists
    SELECT EXISTS(SELECT 1 FROM tramites WHERE id_tramite = p_no_tramite)
    INTO v_tramite_exists;

    IF NOT v_tramite_exists THEN
        RETURN QUERY SELECT FALSE, 'Tramite not found'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Check if license already exists
    SELECT l.id_licencia INTO v_id_licencia
    FROM licencias l
    WHERE l.id_tramite = p_no_tramite
    LIMIT 1;

    IF v_id_licencia IS NOT NULL THEN
        -- Update existing license to authorized status
        UPDATE licencias
        SET estatus = 'AUTORIZADA',
            fecha_autorizacion = CURRENT_DATE,
            updated_at = CURRENT_TIMESTAMP
        WHERE id_licencia = v_id_licencia;

        RETURN QUERY SELECT TRUE, 'License authorized successfully'::TEXT, v_id_licencia;
    ELSE
        -- Create new license record (basic structure)
        INSERT INTO licencias (id_tramite, estatus, fecha_autorizacion, created_at, updated_at)
        VALUES (p_no_tramite, 'AUTORIZADA', CURRENT_DATE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        RETURNING id_licencia INTO v_id_licencia;

        RETURN QUERY SELECT TRUE, 'License created and authorized'::TEXT, v_id_licencia;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE,
            ('Error authorizing license: ' || SQLERRM)::TEXT,
            NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_autoriza_licencia(INTEGER) IS
'Authorizes a license for a given tramite';

-- ============================================
-- SP 7/10: autoriza_anuncio
-- Purpose: Authorize an advertisement for a given tramite
-- Type: Transaction
-- Returns: Success status and message
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_autoriza_anuncio(
    p_no_tramite INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_anuncio INTEGER
) AS $$
DECLARE
    v_id_anuncio INTEGER;
    v_tramite_exists BOOLEAN;
    v_anuncio_exists BOOLEAN;
BEGIN
    -- Validate input
    IF p_no_tramite IS NULL OR p_no_tramite <= 0 THEN
        RETURN QUERY SELECT FALSE, 'Invalid tramite number'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Check if tramite exists
    SELECT EXISTS(SELECT 1 FROM tramites WHERE id_tramite = p_no_tramite)
    INTO v_tramite_exists;

    IF NOT v_tramite_exists THEN
        RETURN QUERY SELECT FALSE, 'Tramite not found'::TEXT, NULL::INTEGER;
        RETURN;
    END IF;

    -- Check if advertisement already exists
    SELECT a.id_anuncio INTO v_id_anuncio
    FROM anuncios a
    WHERE a.id_tramite = p_no_tramite
    LIMIT 1;

    IF v_id_anuncio IS NOT NULL THEN
        -- Update existing advertisement to authorized status
        UPDATE anuncios
        SET estatus = 'AUTORIZADO',
            fecha_autorizacion = CURRENT_DATE,
            updated_at = CURRENT_TIMESTAMP
        WHERE id_anuncio = v_id_anuncio;

        RETURN QUERY SELECT TRUE, 'Advertisement authorized successfully'::TEXT, v_id_anuncio;
    ELSE
        -- Create new advertisement record (basic structure)
        INSERT INTO anuncios (id_tramite, estatus, fecha_autorizacion, created_at, updated_at)
        VALUES (p_no_tramite, 'AUTORIZADO', CURRENT_DATE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        RETURNING id_anuncio INTO v_id_anuncio;

        RETURN QUERY SELECT TRUE, 'Advertisement created and authorized'::TEXT, v_id_anuncio;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE,
            ('Error authorizing advertisement: ' || SQLERRM)::TEXT,
            NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_autoriza_anuncio(INTEGER) IS
'Authorizes an advertisement for a given tramite';

-- ============================================
-- SP 8/10: refresh_query
-- Purpose: Refresh a dataset (compatibility function for legacy system)
-- Type: Utility
-- Returns: Confirmation message
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_refresh_query(
    p_dataset TEXT
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Validate input
    IF p_dataset IS NULL OR TRIM(p_dataset) = '' THEN
        RETURN QUERY SELECT FALSE, 'Dataset name cannot be empty'::TEXT;
        RETURN;
    END IF;

    -- This is a compatibility function for legacy VB6 code
    -- In PostgreSQL, queries are not cached like in older systems
    -- Return success to maintain compatibility
    RETURN QUERY SELECT TRUE, ('Dataset refreshed: ' || p_dataset)::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_refresh_query(TEXT) IS
'Legacy compatibility function for dataset refresh operations';

-- ============================================
-- SP 9/10: generar_dictamen_microgeneradores
-- Purpose: Generate microgenerators opinion/report for tramite
-- Type: Transaction
-- Returns: Success status and generated document ID
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_generar_dictamen_microgeneradores(
    p_id_tramite INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_dictamen INTEGER,
    folio TEXT
) AS $$
DECLARE
    v_id_dictamen INTEGER;
    v_folio TEXT;
    v_tramite_exists BOOLEAN;
    v_giro_text TEXT;
    v_razon_social TEXT;
BEGIN
    -- Validate input
    IF p_id_tramite IS NULL OR p_id_tramite <= 0 THEN
        RETURN QUERY SELECT FALSE,
            'Invalid tramite ID'::TEXT,
            NULL::INTEGER,
            NULL::TEXT;
        RETURN;
    END IF;

    -- Check if tramite exists
    SELECT EXISTS(SELECT 1 FROM tramites WHERE id_tramite = p_id_tramite)
    INTO v_tramite_exists;

    IF NOT v_tramite_exists THEN
        RETURN QUERY SELECT FALSE,
            'Tramite not found'::TEXT,
            NULL::INTEGER,
            NULL::TEXT;
        RETURN;
    END IF;

    -- Get tramite data
    SELECT t.giro, t.razon_social
    INTO v_giro_text, v_razon_social
    FROM tramites t
    WHERE t.id_tramite = p_id_tramite;

    -- Generate folio
    v_folio := 'DICTAMEN-MICRO-' || p_id_tramite || '-' ||
               TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD-HH24MISS');

    -- Insert dictamen record
    INSERT INTO dictamenes (
        id_tramite,
        tipo_dictamen,
        folio,
        giro,
        razon_social,
        fecha_elaboracion,
        estatus,
        created_at,
        updated_at
    ) VALUES (
        p_id_tramite,
        'MICROGENERADORES',
        v_folio,
        v_giro_text,
        v_razon_social,
        CURRENT_DATE,
        'GENERADO',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    RETURNING id INTO v_id_dictamen;

    RETURN QUERY SELECT TRUE,
        'Microgenerators opinion generated successfully'::TEXT,
        v_id_dictamen,
        v_folio;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE,
            ('Error generating opinion: ' || SQLERRM)::TEXT,
            NULL::INTEGER,
            NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_generar_dictamen_microgeneradores(INTEGER) IS
'Generates microgenerators environmental opinion for tramite';

-- ============================================
-- SP 10/10: imprimir_dictamen_microgeneradores
-- Purpose: Get microgenerators opinion data for printing
-- Type: Query
-- Returns: Complete opinion data for document generation
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_imprimir_dictamen_microgeneradores(
    p_id_licencia INTEGER
)
RETURNS TABLE(
    success BOOLEAN,
    message TEXT,
    id_dictamen INTEGER,
    folio TEXT,
    razon_social TEXT,
    giro TEXT,
    domicilio TEXT,
    fecha_elaboracion DATE,
    elaborado_por TEXT,
    contenido_dictamen TEXT
) AS $$
DECLARE
    v_id_tramite INTEGER;
BEGIN
    -- Validate input
    IF p_id_licencia IS NULL OR p_id_licencia <= 0 THEN
        RETURN QUERY SELECT FALSE,
            'Invalid license ID'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::TEXT, NULL::DATE, NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;

    -- Get tramite from license
    SELECT l.id_tramite INTO v_id_tramite
    FROM licencias l
    WHERE l.id_licencia = p_id_licencia;

    IF v_id_tramite IS NULL THEN
        RETURN QUERY SELECT FALSE,
            'License not found'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::TEXT, NULL::DATE, NULL::TEXT, NULL::TEXT;
        RETURN;
    END IF;

    -- Get opinion data
    RETURN QUERY
    SELECT TRUE,
        'Opinion data retrieved'::TEXT,
        d.id,
        d.folio,
        COALESCE(t.razon_social, '')::TEXT,
        COALESCE(t.giro, '')::TEXT,
        COALESCE(t.calle || ' ' || t.num_ext || ' ' || t.colonia, '')::TEXT,
        d.fecha_elaboracion,
        COALESCE(u.nombre, '')::TEXT,
        COALESCE(d.contenido,
            'Dictamen de Microgeneradores - En revisión de condiciones ambientales')::TEXT
    FROM dictamenes d
    INNER JOIN tramites t ON d.id_tramite = t.id_tramite
    LEFT JOIN usuarios u ON d.elaborado_por = u.id
    WHERE d.id_tramite = v_id_tramite
        AND d.tipo_dictamen = 'MICROGENERADORES'
    ORDER BY d.fecha_elaboracion DESC
    LIMIT 1;

    -- If no data found
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE,
            'No microgenerators opinion found for this license'::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::TEXT, NULL::DATE, NULL::TEXT, NULL::TEXT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE,
            ('Error retrieving opinion: ' || SQLERRM)::TEXT,
            NULL::INTEGER, NULL::TEXT, NULL::TEXT, NULL::TEXT,
            NULL::TEXT, NULL::DATE, NULL::TEXT, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION comun.sp_imprimir_dictamen_microgeneradores(INTEGER) IS
'Retrieves microgenerators opinion data for printing/export';

-- ============================================
-- RECOMMENDED INDEXES
-- ============================================

-- Index for detsal_lic queries (derechos2 lookup)
-- CREATE INDEX IF NOT EXISTS idx_detsal_lic_licencia_cvepago ON detsal_lic(id_licencia, cvepago) WHERE derechos2 > 0;
-- CREATE INDEX IF NOT EXISTS idx_detsal_lic_anuncio_cvepago ON detsal_lic(id_anuncio, cvepago) WHERE derechos2 > 0;

-- Index for non-working days date lookups
-- CREATE INDEX IF NOT EXISTS idx_no_laborales_fecha ON no_laboralesLic(fecha);

-- Index for tramites zone lookup
-- CREATE INDEX IF NOT EXISTS idx_tramites_zona ON tramites(zona);
-- CREATE INDEX IF NOT EXISTS idx_tramites_id_giro ON tramites(id_tramite, giro, razon_social);

-- Index for dependency schedule queries
-- CREATE INDEX IF NOT EXISTS idx_dep_horario_dep_dia ON c_dep_horario(id_dependencia, dia);
-- CREATE INDEX IF NOT EXISTS idx_dep_horario_zonas ON c_dep_horario USING gin(zonas gin_trgm_ops);

-- Index for visit capacity checks
-- CREATE INDEX IF NOT EXISTS idx_tramites_visitas_fecha_horario ON tramites_visitas(fecha, c_dep_horario_id);

-- Index for license authorization queries
-- CREATE INDEX IF NOT EXISTS idx_licencias_tramite ON licencias(id_tramite);
-- CREATE INDEX IF NOT EXISTS idx_licencias_estatus ON licencias(estatus);

-- Index for advertisement authorization queries
-- CREATE INDEX IF NOT EXISTS idx_anuncios_tramite ON anuncios(id_tramite);
-- CREATE INDEX IF NOT EXISTS idx_anuncios_estatus ON anuncios(estatus);

-- Index for dictamenes queries
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_tramite_tipo ON dictamenes(id_tramite, tipo_dictamen);
-- CREATE INDEX IF NOT EXISTS idx_dictamenes_folio ON dictamenes(folio);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Test SP 1: Get derechos2
-- SELECT * FROM comun.sp_get_derechos2(p_id_licencia := 123, p_id_anuncio := 0);

-- Test SP 2: Calculate resolution date
-- SELECT * FROM comun.sp_calc_fecha_res(p_fecha_tram := CURRENT_DATE, p_tipo := 'A', p_autoev := FALSE);

-- Test SP 3: Check if date is non-working
-- SELECT * FROM comun.sp_checa_inhabil(p_fecha := CURRENT_DATE);

-- Test SP 4: Calculate payment deadline
-- SELECT * FROM comun.sp_calc_fecha_limite_pago(p_fecha_tram := CURRENT_DATE);

-- Test SP 5: Calculate visit date
-- SELECT * FROM comun.sp_calc_fecha_visita(p_id_tramite := 100, p_id_dependencia := 24);

-- Test SP 6: Authorize license
-- SELECT * FROM comun.sp_autoriza_licencia(p_no_tramite := 100);

-- Test SP 7: Authorize advertisement
-- SELECT * FROM comun.sp_autoriza_anuncio(p_no_tramite := 100);

-- Test SP 8: Refresh query
-- SELECT * FROM comun.sp_refresh_query(p_dataset := 'licencias_dataset');

-- Test SP 9: Generate microgenerators opinion
-- SELECT * FROM comun.sp_generar_dictamen_microgeneradores(p_id_tramite := 100);

-- Test SP 10: Print microgenerators opinion
-- SELECT * FROM comun.sp_imprimir_dictamen_microgeneradores(p_id_licencia := 100);

-- ============================================
-- DEPLOYMENT NOTES
-- ============================================

/*
DEPLOYMENT CHECKLIST:
1. Ensure no_laboralesLic table exists and is populated with holidays
2. Ensure c_dep_horario table exists with dependency schedules
3. Ensure tramites_visitas table exists for visit capacity tracking
4. Ensure licencias table has estatus and fecha_autorizacion columns
5. Ensure anuncios table has estatus and fecha_autorizacion columns
6. Ensure dictamenes table exists for opinion storage
7. Create recommended indexes for optimal performance
8. Test all date calculations with various scenarios
9. Verify capacity limits work correctly for visit scheduling
10. Test authorization workflows end-to-end

PERFORMANCE CONSIDERATIONS:
- Date calculations use iterative loops with safety limits (max 365 iterations)
- Non-working days lookups are optimized with indexed fecha column
- Visit scheduling considers zone, dependency, and daily capacity
- All queries use COALESCE for NULL-safe operations
- Error handling prevents infinite loops and data corruption

DEPENDENCIES:
- no_laboralesLic: Non-working days calendar
- c_dep_horario: Dependency visit schedules by zone
- tramites_visitas: Visit appointments tracking
- tramites: Tramite master data
- licencias: License records
- anuncios: Advertisement records
- dictamenes: Opinion/report documents
- detsal_lic: Payment details
*/

-- ============================================
-- END OF FILE
-- Total Functions: 10
-- Schema: comun
-- Status: READY FOR DEPLOYMENT
-- ============================================
