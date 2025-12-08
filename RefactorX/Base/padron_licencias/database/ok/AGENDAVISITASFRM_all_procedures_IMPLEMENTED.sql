-- ============================================
-- STORED PROCEDURES - BATCH 10
-- Component: Agendavisitasfrm
-- Description: Agenda de visitas de inspección por dependencias gubernamentales
-- Schema: comun (shared functionality)
-- Total SPs: 3
-- Generated: 2025-11-21
-- Status: COMPLETED
-- ============================================
-- PROGRESS: Batch 10/95 - Component 63/95 (66.3%)
-- Previous Batches: 62 components completed
-- ============================================

-- ============================================
-- SP 1/3: sp_get_dependencias
-- Type: Catalog Query
-- Description: Obtiene el catálogo de dependencias gubernamentales disponibles
--              para agendar visitas de inspección.
-- Returns: Lista de dependencias con horarios configurados
-- Dependencies: Tables c_dep_horario, c_dependencias
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_get_dependencias()
RETURNS TABLE (
    id_dependencia INTEGER,
    descripcion VARCHAR
) AS $$
/**
 * Function: sp_get_dependencias
 * Description: Retrieves catalog of government dependencies that have inspection
 *              visit schedules configured. Only returns dependencies with at least
 *              one schedule entry in c_dep_horario.
 *
 * Returns:
 *   - id_dependencia: Unique identifier of the dependency
 *   - descripcion: Name/description of the dependency
 *
 * Business Logic:
 *   - Only dependencies with configured schedules are returned
 *   - Results are grouped by dependency (no duplicates)
 *   - Ordered alphabetically by description for better UX
 *
 * Performance Notes:
 *   - Uses INNER JOIN to filter only dependencies with schedules
 *   - GROUP BY eliminates duplicates if multiple schedules exist
 *
 * Example Usage:
 *   SELECT * FROM comun.sp_get_dependencias();
 *
 * Indexes Required:
 *   - c_dep_horario(id_dependencia) - FK index
 *   - c_dependencias(id_dependencia) - PK index (usually exists)
 *   - c_dependencias(descripcion) - For ORDER BY optimization
 */
BEGIN
    RETURN QUERY
    SELECT
        d.id_dependencia,
        d.descripcion
    FROM comun.c_dep_horario c
    INNER JOIN comun.c_dependencias d ON c.id_dependencia = d.id_dependencia
    GROUP BY d.id_dependencia, d.descripcion
    ORDER BY d.descripcion;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error retrieving dependencies catalog: %', SQLERRM;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_get_dependencias() IS
'Catalog: Returns list of government dependencies with configured inspection schedules';

-- ============================================
-- SP 2/3: sp_get_agenda_visitas
-- Type: Report Query
-- Description: Genera reporte detallado de visitas de inspección agendadas
--              filtrado por dependencia y rango de fechas.
-- Returns: Listado completo de visitas programadas con información del trámite
-- Dependencies: Tables tramites_visitas, c_dep_horario, tramites
--              Function fn_dialetra
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_get_agenda_visitas(
    p_id_dependencia INTEGER,
    p_fechaini DATE,
    p_fechafin DATE
)
RETURNS TABLE (
    fecha DATE,
    dia_letras VARCHAR,
    turno VARCHAR,
    hora VARCHAR,
    zona SMALLINT,
    subzona SMALLINT,
    id_tramite INTEGER,
    feccap DATE,
    propietario VARCHAR,
    domcompleto VARCHAR,
    actividad VARCHAR,
    propietarionvo VARCHAR
) AS $$
/**
 * Function: sp_get_agenda_visitas
 * Description: Generates comprehensive inspection visit schedule report filtered by
 *              government dependency and date range. Includes complete address and
 *              owner information for each scheduled visit.
 *
 * Parameters:
 *   @p_id_dependencia - ID of the government dependency (required)
 *   @p_fechaini - Start date of the report range (required)
 *   @p_fechafin - End date of the report range (required)
 *
 * Returns:
 *   - fecha: Visit date
 *   - dia_letras: Day name in Spanish (Lunes, Martes, etc.)
 *   - turno: Shift (Matutino, Vespertino, etc.)
 *   - hora: Scheduled time
 *   - zona: Zone number
 *   - subzona: Subzone number
 *   - id_tramite: Related procedure ID
 *   - feccap: Capture date of the procedure
 *   - propietario: Original owner name from procedure
 *   - domcompleto: Complete formatted address
 *   - actividad: Business activity description
 *   - propietarionvo: Full owner name (apellido paterno + apellido materno + nombre)
 *
 * Business Logic:
 *   - Filters by dependency through c_dep_horario relationship
 *   - Date range is inclusive (BETWEEN operator)
 *   - Address is formatted with street, external/internal numbers, letters
 *   - Owner name is constructed from separate name fields
 *   - Uses fn_dialetra to convert day number to Spanish day name
 *
 * Validations:
 *   - Dependency ID cannot be null
 *   - Date range must be valid
 *   - Start date must be <= end date
 *
 * Example Usage:
 *   SELECT * FROM comun.sp_get_agenda_visitas(5, '2025-01-01', '2025-01-31');
 *
 * Indexes Required:
 *   - tramites_visitas(c_dep_horario_id, fecha) - Composite for filtering
 *   - tramites_visitas(id_tramite) - FK index
 *   - c_dep_horario(id, id_dependencia) - Composite for joining
 *   - tramites(id_tramite) - PK index
 */
BEGIN
    -- Validate required parameters
    IF p_id_dependencia IS NULL THEN
        RAISE EXCEPTION 'Parameter p_id_dependencia cannot be NULL';
    END IF;

    IF p_fechaini IS NULL THEN
        RAISE EXCEPTION 'Parameter p_fechaini cannot be NULL';
    END IF;

    IF p_fechafin IS NULL THEN
        RAISE EXCEPTION 'Parameter p_fechafin cannot be NULL';
    END IF;

    -- Validate date range
    IF p_fechaini > p_fechafin THEN
        RAISE EXCEPTION 'Start date (%) cannot be greater than end date (%)',
            p_fechaini, p_fechafin;
    END IF;

    RETURN QUERY
    SELECT
        v.fecha,
        comun.fn_dialetra(EXTRACT(DOW FROM v.fecha)::INTEGER) AS dia_letras,
        COALESCE(v.turno, '')::VARCHAR AS turno,
        COALESCE(v.hora, '')::VARCHAR AS hora,
        COALESCE(v.zona, 0)::SMALLINT AS zona,
        COALESCE(v.subzona, 0)::SMALLINT AS subzona,
        v.id_tramite,
        t.feccap,
        COALESCE(t.propietario, '')::VARCHAR AS propietario,
        (
            TRIM(COALESCE(v.ubicacion, '')) ||
            ' No. ext.: ' || COALESCE(v.numext_ubic, '') ||
            ' Letra ext.: ' || COALESCE(v.letraext_ubic, '') ||
            ' No. int.: ' || COALESCE(v.numint_ubic, '') ||
            ' Letra int.: ' || COALESCE(v.letraint_ubic, '')
        )::VARCHAR AS domcompleto,
        COALESCE(v.actividad, '')::VARCHAR AS actividad,
        TRIM(
            COALESCE(t.primer_ap, '') || ' ' ||
            COALESCE(t.segundo_ap, '') || ' ' ||
            COALESCE(t.propietario, '')
        )::VARCHAR AS propietarionvo
    FROM comun.tramites_visitas v
    INNER JOIN comun.c_dep_horario h
        ON h.id = v.c_dep_horario_id
        AND h.id_dependencia = p_id_dependencia
    INNER JOIN comun.tramites t
        ON t.id_tramite = v.id_tramite
    WHERE v.fecha BETWEEN p_fechaini AND p_fechafin
    ORDER BY v.fecha, v.hora, v.zona, v.subzona;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error generating visit schedule report: %', SQLERRM;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION comun.sp_get_agenda_visitas(INTEGER, DATE, DATE) IS
'Report: Returns scheduled inspection visits filtered by dependency and date range';

-- ============================================
-- SP 3/3: fn_dialetra
-- Type: Utility Function
-- Description: Convierte número de día (0-6) a nombre del día en español.
--              Utilizado para formatear fechas en reportes.
-- Returns: Nombre del día en español
-- Dependencies: None (standalone utility)
-- ============================================

CREATE OR REPLACE FUNCTION comun.fn_dialetra(p_dia INTEGER)
RETURNS VARCHAR AS $$
/**
 * Function: fn_dialetra
 * Description: Converts day number (0-6) to Spanish day name. This utility function
 *              is used across the system for date formatting in reports and displays.
 *
 * Parameters:
 *   @p_dia - Day number (0=Domingo, 1=Lunes, 2=Martes, 3=Miércoles,
 *            4=Jueves, 5=Viernes, 6=Sábado)
 *
 * Returns:
 *   - Spanish day name (VARCHAR)
 *   - Empty string if p_dia is NULL or out of range
 *
 * Business Logic:
 *   - Uses PostgreSQL array for O(1) lookup
 *   - Day 0 = Sunday (PostgreSQL EXTRACT(DOW) convention)
 *   - Array is 1-indexed, so we add 1 to the day number
 *   - Returns empty string for invalid input instead of error
 *
 * Validation:
 *   - Returns '' if p_dia is NULL
 *   - Returns '' if p_dia < 0 or p_dia > 6
 *
 * Performance:
 *   - IMMUTABLE function - can be cached by PostgreSQL
 *   - No table access - pure computation
 *   - Array lookup is O(1) complexity
 *
 * Example Usage:
 *   SELECT comun.fn_dialetra(0);  -- Returns 'Domingo'
 *   SELECT comun.fn_dialetra(1);  -- Returns 'Lunes'
 *   SELECT comun.fn_dialetra(EXTRACT(DOW FROM CURRENT_DATE)::INTEGER);
 *
 * Integration:
 *   - Used by sp_get_agenda_visitas for date formatting
 *   - Can be used in any report requiring Spanish day names
 */
DECLARE
    v_dias TEXT[] := ARRAY['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
BEGIN
    -- Validate input range
    IF p_dia IS NULL OR p_dia < 0 OR p_dia > 6 THEN
        RETURN '';
    END IF;

    -- Return day name from array (arrays are 1-indexed in PostgreSQL)
    RETURN v_dias[p_dia + 1];

EXCEPTION
    WHEN OTHERS THEN
        -- Fail gracefully - return empty string instead of error
        RETURN '';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION comun.fn_dialetra(INTEGER) IS
'Utility: Converts day number (0-6) to Spanish day name (Domingo-Sábado)';

-- ============================================
-- RECOMMENDED INDEXES FOR OPTIMAL PERFORMANCE
-- ============================================

-- These indexes should be created if they don't exist:

-- Index 1: Optimize dependency catalog retrieval
-- CREATE INDEX IF NOT EXISTS idx_dep_horario_id_dependencia
--     ON comun.c_dep_horario(id_dependencia);

-- Index 2: Optimize dependency sorting
-- CREATE INDEX IF NOT EXISTS idx_dependencias_descripcion
--     ON comun.c_dependencias(descripcion);

-- Index 3: Composite index for visit schedule filtering
-- CREATE INDEX IF NOT EXISTS idx_tramites_visitas_horario_fecha
--     ON comun.tramites_visitas(c_dep_horario_id, fecha);

-- Index 4: FK index for visits to procedures join
-- CREATE INDEX IF NOT EXISTS idx_tramites_visitas_id_tramite
--     ON comun.tramites_visitas(id_tramite);

-- Index 5: Composite index for schedule lookup
-- CREATE INDEX IF NOT EXISTS idx_dep_horario_id_dependencia
--     ON comun.c_dep_horario(id, id_dependencia);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Test 1: Verify sp_get_dependencias returns results
-- Expected: List of dependencies with configured schedules
-- SELECT * FROM comun.sp_get_dependencias();

-- Test 2: Verify fn_dialetra works correctly
-- Expected: 'Lunes' for Monday (1), 'Viernes' for Friday (5)
-- SELECT comun.fn_dialetra(1) as lunes, comun.fn_dialetra(5) as viernes;

-- Test 3: Verify fn_dialetra handles invalid input
-- Expected: Empty strings for NULL and out-of-range values
-- SELECT
--     comun.fn_dialetra(NULL) as null_test,
--     comun.fn_dialetra(-1) as negative_test,
--     comun.fn_dialetra(7) as overflow_test;

-- Test 4: Verify sp_get_agenda_visitas with valid parameters
-- Expected: List of scheduled visits for dependency 1 in January 2025
-- SELECT * FROM comun.sp_get_agenda_visitas(
--     1,
--     '2025-01-01'::DATE,
--     '2025-01-31'::DATE
-- );

-- Test 5: Verify parameter validation (should raise exception)
-- Expected: Error message about NULL parameter
-- SELECT * FROM comun.sp_get_agenda_visitas(NULL, '2025-01-01', '2025-01-31');

-- Test 6: Verify date range validation (should raise exception)
-- Expected: Error message about invalid date range
-- SELECT * FROM comun.sp_get_agenda_visitas(1, '2025-02-01', '2025-01-01');

-- Test 7: Check function exists in correct schema
-- Expected: All 3 functions listed
-- SELECT
--     routine_name,
--     routine_type,
--     data_type as return_type
-- FROM information_schema.routines
-- WHERE routine_schema = 'comun'
--     AND routine_name IN ('sp_get_dependencias', 'sp_get_agenda_visitas', 'fn_dialetra')
-- ORDER BY routine_name;

-- Test 8: Verify function parameters
-- Expected: Parameter details for sp_get_agenda_visitas
-- SELECT
--     parameter_name,
--     data_type,
--     parameter_mode
-- FROM information_schema.parameters
-- WHERE specific_schema = 'comun'
--     AND specific_name LIKE '%sp_get_agenda_visitas%'
-- ORDER BY ordinal_position;

-- ============================================
-- DEPLOYMENT NOTES
-- ============================================

-- Component: Agendavisitasfrm
-- Total Functions: 3
-- Schema: comun (shared)
-- Dependencies:
--   - Tables: c_dep_horario, c_dependencias, tramites_visitas, tramites
--   - Functions: fn_dialetra (self-contained in this file)
--
-- Deployment Order:
--   1. fn_dialetra (no dependencies)
--   2. sp_get_dependencias (table dependencies only)
--   3. sp_get_agenda_visitas (depends on fn_dialetra)
--
-- Rollback Strategy:
--   DROP FUNCTION IF EXISTS comun.sp_get_agenda_visitas(INTEGER, DATE, DATE);
--   DROP FUNCTION IF EXISTS comun.sp_get_dependencias();
--   DROP FUNCTION IF EXISTS comun.fn_dialetra(INTEGER);
--
-- Testing Checklist:
--   [✓] All functions use FUNCTION (not PROCEDURE)
--   [✓] All parameters have p_ prefix
--   [✓] All variables have v_ prefix
--   [✓] Schema is specified (comun)
--   [✓] RETURNS TABLE used correctly
--   [✓] Error handling included with RAISE EXCEPTION
--   [✓] Input validation implemented
--   [✓] COALESCE used for NULL handling
--   [✓] Indexes recommended in comments
--   [✓] Comprehensive documentation added
--   [✓] Verification queries provided

-- ============================================
-- END OF IMPLEMENTATION
-- Component: Agendavisitasfrm - COMPLETED ✓
-- Batch 10 Progress: 63/95 components (66.3%)
-- ============================================
