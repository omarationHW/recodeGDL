-- ============================================
-- STORED PROCEDURES CONSOLIDADOS - IMPLEMENTADOS
-- Component: formabuscalle
-- Description: Búsqueda y listado de calles (Street Search and Listing)
-- Batch: 11
-- Progress: 67/95 components (70.5%)
-- Generated: 2025-11-21
-- Total SPs: 2
-- ============================================
--
-- BUSINESS LOGIC:
-- - Búsqueda de calles por nombre (case-insensitive)
-- - Listado completo de calles
-- - Exclusión de calles ocultas (vigente='V' AND num_tag=8000)
-- - Retorna 8 campos de información de calle
--
-- TABLES INVOLVED:
-- - comun.c_calles (main catalog)
-- - comun.c_calles_escondidas (hidden streets exclusion list)
--
-- ============================================

-- ============================================
-- SP 1/2: sp_buscar_calles
-- Type: Search/Query
-- Description: Busca calles cuyo nombre contenga el filtro (case-insensitive),
--              excluyendo las calles ocultas (vigente='V' AND num_tag=8000)
-- Parameters:
--   p_filtro: Texto a buscar en el nombre de la calle
-- Returns: TABLE con información completa de calles
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_buscar_calles(
    p_filtro TEXT
)
RETURNS TABLE(
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig VARCHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    -- Validation: filtro parameter is required
    IF p_filtro IS NULL OR TRIM(p_filtro) = '' THEN
        RAISE EXCEPTION 'El parámetro de búsqueda (filtro) es requerido y no puede estar vacío';
    END IF;

    -- Search streets by name (case-insensitive) excluding hidden streets
    RETURN QUERY
    SELECT
        cc.cvecalle,
        cc.cvepoblacion,
        cc.desvial,
        cc.calle,
        cc.cvevig,
        cc.anterior,
        cc.feccap,
        cc.capturista
    FROM comun.c_calles cc
    WHERE cc.calle ILIKE '%' || p_filtro || '%'
      AND cc.cvecalle NOT IN (
          SELECT cce.cvecalle
          FROM comun.c_calles_escondidas cce
          WHERE cce.vigente = 'V'
            AND cce.num_tag = 8000
      )
    ORDER BY cc.calle;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al buscar calles: % - %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SP 2/2: sp_listar_calles
-- Type: List/Query
-- Description: Lista todas las calles excluyendo las ocultas
--              (vigente='V' AND num_tag=8000)
-- Parameters: None
-- Returns: TABLE con información completa de calles
-- ============================================

CREATE OR REPLACE FUNCTION comun.sp_listar_calles()
RETURNS TABLE(
    cvecalle INTEGER,
    cvepoblacion INTEGER,
    desvial INTEGER,
    calle VARCHAR(40),
    cvevig VARCHAR(1),
    anterior INTEGER,
    feccap DATE,
    capturista VARCHAR(10)
) AS $$
BEGIN
    -- List all streets excluding hidden ones
    RETURN QUERY
    SELECT
        cc.cvecalle,
        cc.cvepoblacion,
        cc.desvial,
        cc.calle,
        cc.cvevig,
        cc.anterior,
        cc.feccap,
        cc.capturista
    FROM comun.c_calles cc
    WHERE cc.cvecalle NOT IN (
          SELECT cce.cvecalle
          FROM comun.c_calles_escondidas cce
          WHERE cce.vigente = 'V'
            AND cce.num_tag = 8000
      )
    ORDER BY cc.calle;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al listar calles: % - %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- RECOMMENDED INDEXES
-- ============================================

-- Index for street name search (ILIKE operations)
-- CREATE INDEX IF NOT EXISTS idx_c_calles_calle_search ON comun.c_calles USING gin(calle gin_trgm_ops);
-- Note: Requires pg_trgm extension: CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Alternative index for standard LIKE operations
-- CREATE INDEX IF NOT EXISTS idx_c_calles_calle ON comun.c_calles(calle);

-- Index for primary key lookup
-- CREATE INDEX IF NOT EXISTS idx_c_calles_cvecalle ON comun.c_calles(cvecalle);

-- Index for hidden streets exclusion subquery
-- CREATE INDEX IF NOT EXISTS idx_c_calles_escondidas_lookup ON comun.c_calles_escondidas(cvecalle, vigente, num_tag)
-- WHERE vigente = 'V' AND num_tag = 8000;

-- Index for ordering results
-- CREATE INDEX IF NOT EXISTS idx_c_calles_calle_order ON comun.c_calles(calle);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Test 1: Search streets containing 'JUAREZ'
-- SELECT * FROM comun.sp_buscar_calles('JUAREZ');

-- Test 2: Search streets containing 'av' (case-insensitive)
-- SELECT * FROM comun.sp_buscar_calles('av');

-- Test 3: List all non-hidden streets (first 10)
-- SELECT * FROM comun.sp_listar_calles() LIMIT 10;

-- Test 4: Count total non-hidden streets
-- SELECT COUNT(*) as total_calles FROM comun.sp_listar_calles();

-- Test 5: Verify hidden streets are excluded
-- SELECT cvecalle, calle FROM comun.c_calles
-- WHERE cvecalle IN (SELECT cvecalle FROM comun.c_calles_escondidas WHERE vigente = 'V' AND num_tag = 8000)
-- AND cvecalle IN (SELECT cvecalle FROM comun.sp_listar_calles());
-- Expected: 0 rows (hidden streets should not appear)

-- Test 6: Error handling - empty filter
-- SELECT * FROM comun.sp_buscar_calles('');
-- Expected: Exception raised

-- Test 7: Error handling - null filter
-- SELECT * FROM comun.sp_buscar_calles(NULL);
-- Expected: Exception raised

-- ============================================
-- PERFORMANCE NOTES
-- ============================================
--
-- 1. ILIKE Pattern Matching:
--    - ILIKE with leading wildcard ('%text%') cannot use standard B-tree indexes
--    - Consider pg_trgm (trigram) indexes for better performance
--    - For large datasets, full-text search may be more efficient
--
-- 2. NOT IN Subquery:
--    - NOT IN with subquery is generally efficient for small exclusion lists
--    - Alternative: LEFT JOIN with WHERE excluded.id IS NULL
--    - Alternative: NOT EXISTS correlated subquery
--
-- 3. Ordering:
--    - ORDER BY calle benefits from index on calle column
--    - Consider adding index if datasets are large
--
-- 4. Hidden Streets Exclusion:
--    - Filtered index on c_calles_escondidas can improve subquery performance
--    - Consider materialized view if hidden streets list is static
--
-- ============================================
-- MIGRATION NOTES
-- ============================================
--
-- Original MySQL patterns transformed to PostgreSQL:
-- 1. LIKE -> ILIKE (case-insensitive by default)
-- 2. CONCAT() -> || operator
-- 3. Added proper schema prefix (comun)
-- 4. Added parameter prefix (p_)
-- 5. Added explicit error handling
-- 6. Added input validation
-- 7. Added ORDER BY for consistent results
-- 8. Used FUNCTION instead of PROCEDURE
-- 9. RETURNS TABLE pattern for result sets
--
-- ============================================
-- END OF FILE
-- ============================================
